Rails.application.config.after_initialize do
  begin
    if ActiveRecord::Base.connection.table_exists?("system_settings")
      aws_access_key = ActiveRecord::Base.connection.select_value(
        "SELECT value FROM system_settings WHERE key = 'aws_access_key_id' LIMIT 1"
      )
      aws_secret_key = ActiveRecord::Base.connection.select_value(
        "SELECT value FROM system_settings WHERE key = 'aws_secret_access_key' LIMIT 1"
      )
      aws_region = ActiveRecord::Base.connection.select_value(
        "SELECT value FROM system_settings WHERE key = 'aws_region' LIMIT 1"
      )
      aws_bucket = ActiveRecord::Base.connection.select_value(
        "SELECT value FROM system_settings WHERE key = 'aws_bucket' LIMIT 1"
      )

      ENV["AWS_ACCESS_KEY_ID"] = aws_access_key if aws_access_key.present?
      ENV["AWS_SECRET_ACCESS_KEY"] = aws_secret_key if aws_secret_key.present?
      ENV["AWS_REGION"] = aws_region if aws_region.present?
      ENV["AWS_BUCKET"] = aws_bucket if aws_bucket.present?

      if aws_bucket.present? && aws_access_key.present? && aws_secret_key.present?
        Rails.logger.info "AWS S3 credentials found in SystemSettings — configuring Active Storage with S3 (bucket=#{aws_bucket}, region=#{aws_region})"
        configure_active_storage_s3(aws_access_key, aws_secret_key, aws_region || "ap-southeast-1", aws_bucket)
      else
        Rails.logger.info "AWS S3 credentials not configured — using local storage. Add credentials in Admin > System Settings > AWS and restart the server."
      end
    end
  rescue => e
    Rails.logger.warn "Could not load AWS settings from DB: #{e.message}"
  end
end

def configure_active_storage_s3(access_key_id, secret_access_key, region, bucket)
  require "aws-sdk-s3"
  config = {
    amazon: {
      service: "S3",
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      region: region,
      bucket: bucket
    }
  }
  ActiveStorage::Blob.service = ActiveStorage::Service.configure(:amazon, config)
  Rails.logger.info "Active Storage switched to S3 successfully"
rescue => e
  Rails.logger.warn "Could not configure Active Storage S3, falling back to local: #{e.message}"
end
