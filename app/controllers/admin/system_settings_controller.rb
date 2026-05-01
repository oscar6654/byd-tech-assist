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
    redirect_to admin_system_settings_path, notice: "Settings updated successfully."
  end

  def test_email
    test_address = params[:test_email_address].presence || current_user.email
    begin
      configure_mailer_from_settings!
      TestMailer.test_email(test_address).deliver_now
      SystemSetting.find_by(key: "mailgun_api_key")&.update(test_status: "success", last_tested_at: Time.current)
      redirect_to admin_system_settings_path, notice: "Test email sent to #{test_address}."
    rescue => e
      SystemSetting.find_by(key: "mailgun_api_key")&.update(test_status: "failed", last_tested_at: Time.current)
      redirect_to admin_system_settings_path, alert: "Email test failed: #{e.message}"
    end
  end

  def test_aws
    begin
      require "aws-sdk-s3"
      client = Aws::S3::Client.new(
        access_key_id: SystemSetting.get("aws_access_key_id"),
        secret_access_key: SystemSetting.get("aws_secret_access_key"),
        region: SystemSetting.get("aws_region", "ap-southeast-1")
      )
      bucket = SystemSetting.get("aws_bucket")
      client.list_objects_v2(bucket: bucket, max_keys: 1)
      SystemSetting.find_by(key: "aws_access_key_id")&.update(test_status: "success", last_tested_at: Time.current)
      redirect_to admin_system_settings_path, notice: "AWS S3 connection successful."
    rescue => e
      SystemSetting.find_by(key: "aws_access_key_id")&.update(test_status: "failed", last_tested_at: Time.current)
      redirect_to admin_system_settings_path, alert: "AWS test failed: #{e.message}"
    end
  end

  private

  def configure_mailer_from_settings!
    provider = SystemSetting.get("email_provider", "smtp")
    if provider == "mailgun"
      api_key = SystemSetting.get("mailgun_api_key")
      domain = SystemSetting.get("mailgun_domain")
      raise "Mailgun API key is not configured" if api_key.blank?
      raise "Mailgun domain is not configured" if domain.blank?
      ActionMailer::Base.delivery_method = :mailgun
      ActionMailer::Base.mailgun_settings = { api_key: api_key, domain: domain }
    else
      raise "Email provider is set to '#{provider}'. Change it to 'mailgun', save settings, then test."
    end
  end
end
