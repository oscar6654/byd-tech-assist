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
      ) || "ap-southeast-1"
      aws_bucket = ActiveRecord::Base.connection.select_value(
        "SELECT value FROM system_settings WHERE key = 'aws_bucket' LIMIT 1"
      )

      ENV["AWS_ACCESS_KEY_ID"] = aws_access_key if aws_access_key.present?
      ENV["AWS_SECRET_ACCESS_KEY"] = aws_secret_key if aws_secret_key.present?
      ENV["AWS_REGION"] = aws_region if aws_region.present?
      ENV["AWS_BUCKET"] = aws_bucket if aws_bucket.present?

      if aws_bucket.present? && aws_access_key.present? && aws_secret_key.present?
        Rails.logger.info "AWS ENV loaded from SystemSettings: bucket=#{aws_bucket}, region=#{aws_region}"

        amazon_config = {
          "service" => "S3",
          "access_key_id" => aws_access_key,
          "secret_access_key" => aws_secret_key,
          "region" => aws_region,
          "bucket" => aws_bucket
        }

        configs = Rails.configuration.active_storage.service_configurations ||= {}
        configs["amazon"] = amazon_config

        ActiveStorage::Blob.services = ActiveStorage::Service::Registry.new(configs)
        ActiveStorage::Blob.service = ActiveStorage::Blob.services.fetch(:amazon)

        Rails.configuration.active_storage.service = :amazon

        Rails.logger.info "ActiveStorage S3 configured for bucket '#{aws_bucket}' in region '#{aws_region}'"
      else
        Rails.logger.info "AWS S3 credentials not fully configured — using local storage"
      end
    end
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid => e
    Rails.logger.warn "Could not load AWS settings from database: #{e.message}"
  rescue => e
    Rails.logger.warn "Could not configure AWS: #{e.message}"
  end
end
