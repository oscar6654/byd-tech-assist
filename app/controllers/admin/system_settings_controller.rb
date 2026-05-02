class Admin::SystemSettingsController < ApplicationController
  before_action :require_admin!

  def index
    @email_settings = SystemSetting.by_category("email")
    @aws_settings = SystemSetting.by_category("aws")
    @branding_settings = SystemSetting.by_category("branding")
  end

  def update_settings
    params[:settings]&.each do |key, value|
      SystemSetting.set(key, value, category: SystemSetting.infer_category(key))
    end
    SystemSetting.invalidate_cache if SystemSetting.respond_to?(:invalidate_cache)
    redirect_to admin_system_settings_path, notice: "Settings updated successfully."
  end

  def test_email
    test_address = params[:test_email_address].presence || current_user.email

    result = CredentialTesterService.test_email(test_address)

    SystemSetting.find_by(key: "mailgun_api_key")&.update(
      last_tested_at: Time.current,
      test_status: result[:success] ? "success" : "failed"
    )

    if result[:success]
      redirect_to admin_system_settings_path, notice: result[:message]
    else
      redirect_to admin_system_settings_path, alert: result[:message]
    end
  end

  def test_aws
    result = CredentialTesterService.test_aws

    SystemSetting.find_by(key: "aws_access_key_id")&.update(
      last_tested_at: Time.current,
      test_status: result[:success] ? "success" : "failed"
    )

    if result[:success]
      redirect_to admin_system_settings_path, notice: result[:message]
    else
      redirect_to admin_system_settings_path, alert: result[:message]
    end
  end
end
