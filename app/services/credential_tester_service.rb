class CredentialTesterService
  class << self
    def test_email(to_email)
      provider = SystemSetting.get("email_provider", "smtp")

      if provider == "mailgun"
        test_email_mailgun(to_email)
      else
        test_email_smtp(to_email)
      end
    end

    def test_email_mailgun(to_email)
      api_key = SystemSetting.get("mailgun_api_key")
      domain = SystemSetting.get("mailgun_domain")
      from_email = SystemSetting.get("default_from_email", "noreply@#{domain}")

      return { success: false, message: "Mailgun API key is not configured" } if api_key.blank?
      return { success: false, message: "Mailgun domain is not configured" } if domain.blank?

      require "mailgun-ruby"

      mg_client = Mailgun::Client.new(api_key)

      company_name = SystemSetting.get("company_name", "BYD Tech Assist")

      message_params = {
        from: from_email,
        to: to_email,
        subject: "Test Email from #{company_name}",
        text: "This is a test email to verify your Mailgun configuration is working correctly.\n\nIf you received this email, your email settings are configured properly.\n\nSent at: #{Time.current}",
        html: <<~HTML
          <html>
            <body style="font-family: Arial, sans-serif; padding: 20px;">
              <h2>Test Email</h2>
              <p>This is a test email to verify your Mailgun configuration is working correctly.</p>
              <p>If you received this email, your email settings are configured properly.</p>
              <hr>
              <p style="color: #666; font-size: 12px;">Sent from #{company_name}</p>
            </body>
          </html>
        HTML
      }

      response = mg_client.send_message(domain, message_params)

      if response.code == 200
        { success: true, message: "Test email sent successfully to #{to_email}" }
      else
        { success: false, message: "Failed to send email: #{response.body}" }
      end
    rescue Mailgun::CommunicationError => e
      { success: false, message: "Mailgun communication error: #{e.message}" }
    rescue Mailgun::Error => e
      { success: false, message: "Mailgun error: #{e.message}" }
    rescue StandardError => e
      { success: false, message: "Error: #{e.message}" }
    end

    def test_email_smtp(to_email)
      { success: false, message: "SMTP is not yet configured. Use Mailgun as the email provider." }
    end

    def test_aws
      access_key_id = SystemSetting.get("aws_access_key_id")
      secret_access_key = SystemSetting.get("aws_secret_access_key")
      region = SystemSetting.get("aws_region", "ap-southeast-1")
      bucket = SystemSetting.get("aws_bucket")

      return { success: false, message: "AWS Access Key ID is not configured" } if access_key_id.blank?
      return { success: false, message: "AWS Secret Access Key is not configured" } if secret_access_key.blank?
      return { success: false, message: "AWS Bucket is not configured" } if bucket.blank?

      require "aws-sdk-s3"

      client = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region
      )

      client.list_objects_v2(bucket: bucket, max_keys: 1)

      { success: true, message: "AWS S3 connection successful. Bucket '#{bucket}' accessible." }
    rescue Aws::S3::Errors::InvalidAccessKeyId
      { success: false, message: "Invalid AWS Access Key ID" }
    rescue Aws::S3::Errors::SignatureDoesNotMatch
      { success: false, message: "Invalid AWS Secret Access Key" }
    rescue Aws::S3::Errors::NoSuchBucket
      { success: false, message: "Bucket '#{bucket}' does not exist" }
    rescue Aws::S3::Errors::AccessDenied
      { success: false, message: "Access denied to bucket '#{bucket}'. Check your permissions." }
    rescue StandardError => e
      { success: false, message: "AWS Error: #{e.message}" }
    end
  end
end
