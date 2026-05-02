require "mailgun-ruby"

class MailgunDeliveryMethod
  attr_accessor :settings

  def initialize(settings)
    @settings = settings
  end

  def deliver!(mail)
    api_key = @settings[:api_key]
    domain = @settings[:domain]

    if api_key.blank?
      api_key = SystemSetting.get("mailgun_api_key") rescue nil
    end
    if domain.blank?
      domain = SystemSetting.get("mailgun_domain") rescue nil
    end

    unless api_key.present? && domain.present?
      Rails.logger.error "Mailgun: API key or domain not configured in System Settings"
      raise "Mailgun API key or domain not configured. Go to Admin > System Settings > Email to configure."
    end

    mg_client = Mailgun::Client.new(api_key)

    message_params = {
      from: mail.from&.first || SystemSetting.get("default_from_email", "noreply@valuesalesinc.com"),
      to: mail.to&.join(", "),
      subject: mail.subject
    }

    message_params[:text] = mail.text_part.body.to_s if mail.text_part
    message_params[:html] = mail.html_part.body.to_s if mail.html_part
    message_params[:html] ||= mail.body.to_s if mail.content_type&.include?("text/html")
    message_params[:text] ||= mail.body.to_s unless message_params[:html]

    message_params[:cc] = mail.cc.join(", ") if mail.cc.present?
    message_params[:bcc] = mail.bcc.join(", ") if mail.bcc.present?

    response = mg_client.send_message(domain, message_params)
    Rails.logger.info "Mailgun: Email sent to #{mail.to&.join(', ')} - Response: #{response.code}"
    response
  rescue Mailgun::Error => e
    Rails.logger.error "Mailgun delivery failed: #{e.message}"
    raise e
  end
end

ActionMailer::Base.add_delivery_method :mailgun, MailgunDeliveryMethod,
  api_key: nil,
  domain: nil

Rails.application.config.after_initialize do
  begin
    if ActiveRecord::Base.connection.table_exists?("system_settings")
      email_provider = SystemSetting.get("email_provider", "smtp")

      from_email = SystemSetting.get("default_from_email")
      if from_email.present?
        ActionMailer::Base.default_options = { from: from_email }
      end

      if email_provider == "mailgun"
        api_key = SystemSetting.get("mailgun_api_key")
        domain = SystemSetting.get("mailgun_domain")
        if api_key.present? && domain.present?
          ActionMailer::Base.delivery_method = :mailgun
          ActionMailer::Base.mailgun_settings = { api_key: api_key, domain: domain }
          Rails.logger.info "Mailgun delivery configured for domain #{domain}"
        end
      end
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Could not configure Mailgun: #{e.message}"
  end
end
