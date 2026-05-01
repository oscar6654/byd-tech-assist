class SystemSetting < ApplicationRecord
  CATEGORIES = %w[email aws branding].freeze
  VALUE_TYPES = %w[string integer decimal boolean].freeze

  validates :key, presence: true, uniqueness: true
  validates :value_type, inclusion: { in: VALUE_TYPES }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  scope :by_category, ->(cat) { where(category: cat) }

  def self.get(key, default = nil)
    Rails.cache.fetch("system_setting/#{key}", expires_in: 5.minutes) do
      setting = find_by(key: key)
      return default unless setting
      setting.typed_value
    end
  rescue
    default
  end

  def self.set(key, value, value_type: "string", description: nil, category: "general")
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.value_type = value_type
    setting.description = description if description.present?
    setting.category = category if category.present?
    setting.save!
    Rails.cache.delete("system_setting/#{key}")
    setting
  end

  def typed_value
    case value_type
    when "integer"
      value.to_i
    when "decimal"
      value.to_f
    when "boolean"
      %w[true 1 yes].include?(value.to_s.downcase)
    else
      value
    end
  end

  def self.testable_keys
    %w[mailgun_api_key mailgun_domain aws_access_key_id aws_secret_access_key aws_bucket]
  end

  def self.infer_category(key)
    case key.to_s
    when /^mailgun_/, /^smtp_/, /^email_/, /^default_from/
      "email"
    when /^aws_/
      "aws"
    when /^company_/, /^app_/
      "branding"
    else
      "general"
    end
  end
end
