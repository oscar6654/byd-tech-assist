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
      Rails.logger.error "Mailgun: API key or domain not configured"
      raise "Mailgun API key or domain not configured. Go to Admin > System Settings > Email to configure."
    end

    mg_client = Mailgun::Client.new(api_key)
    message_builder = Mailgun::MessageBuilder.new

    message_builder.from(mail.from.first)
    Array(mail.to).each { |to| message_builder.add_recipient(:to, to) }
    Array(mail.cc).each { |cc| message_builder.add_recipient(:cc, cc) } if mail.cc.present?
    Array(mail.bcc).each { |bcc| message_builder.add_recipient(:bcc, bcc) } if mail.bcc.present?
    message_builder.subject(mail.subject)

    if mail.html_part
      message_builder.body_html(mail.html_part.body.to_s)
    end
    if mail.text_part
      message_builder.body_text(mail.text_part.body.to_s)
    elsif !mail.html_part
      message_builder.body_text(mail.body.to_s)
    end

    mg_client.send_message(domain, message_builder)
  end
end

ActionMailer::Base.add_delivery_method :mailgun, MailgunDeliveryMethod

Rails.application.config.after_initialize do
  begin
    if defined?(SystemSetting) && ActiveRecord::Base.connection.table_exists?("system_settings")
      email_provider = SystemSetting.get("email_provider", "smtp")
      if email_provider == "mailgun"
        api_key = SystemSetting.get("mailgun_api_key")
        domain = SystemSetting.get("mailgun_domain")
        if api_key.present? && domain.present?
          ActionMailer::Base.delivery_method = :mailgun
          ActionMailer::Base.mailgun_settings = { api_key: api_key, domain: domain }
          Rails.logger.info "Mailgun delivery configured"
        end
      end
    end
  rescue => e
    Rails.logger.warn "Could not configure Mailgun: #{e.message}"
  end
end
