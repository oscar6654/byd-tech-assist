puts "Seeding system settings..."

default_settings = [
  { key: "email_provider", value: "smtp", value_type: "string", category: "email", description: "Email delivery provider (smtp or mailgun)" },
  { key: "mailgun_api_key", value: "", value_type: "string", category: "email", description: "Mailgun API key" },
  { key: "mailgun_domain", value: "", value_type: "string", category: "email", description: "Mailgun sending domain" },
  { key: "default_from_email", value: "noreply@bydtechassist.com", value_type: "string", category: "email", description: "Default from email address" },
  { key: "aws_access_key_id", value: "", value_type: "string", category: "aws", description: "AWS access key ID" },
  { key: "aws_secret_access_key", value: "", value_type: "string", category: "aws", description: "AWS secret access key" },
  { key: "aws_region", value: "ap-southeast-1", value_type: "string", category: "aws", description: "AWS S3 region" },
  { key: "aws_bucket", value: "", value_type: "string", category: "aws", description: "AWS S3 bucket name" },
  { key: "company_name", value: "BYD Tech Assist Center", value_type: "string", category: "branding", description: "Company name" },
  { key: "app_name", value: "BYD Tech Assist", value_type: "string", category: "branding", description: "Application name" },
]

default_settings.each do |setting|
  SystemSetting.find_or_create_by!(key: setting[:key]) do |s|
    s.value = setting[:value]
    s.value_type = setting[:value_type]
    s.category = setting[:category]
    s.description = setting[:description]
  end
end

puts "Creating admin user..."
admin = User.find_or_initialize_by(email: "admin@bydtechassist.com")
admin.assign_attributes(
  first_name: "Admin",
  last_name: "User",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  active: true,
  confirmed_at: Time.current
)
admin.save!

puts "Seeding BYD models..."
byd_models = [
  { name: "Atto 3", model_code: "ATTO3" },
  { name: "Dolphin", model_code: "DOLPHIN" },
  { name: "Seal", model_code: "SEAL" },
  { name: "Seal U", model_code: "SEALU" },
  { name: "Seal U DM-i", model_code: "SEALUDMI" },
  { name: "Han", model_code: "HAN" },
  { name: "Tang", model_code: "TANG" },
  { name: "M6", model_code: "M6" },
  { name: "Shark", model_code: "SHARK" },
  { name: "Sealion 6", model_code: "SL6" },
  { name: "Sealion 7", model_code: "SL7" },
]

byd_models.each do |model|
  BydModel.find_or_create_by!(name: model[:name]) do |m|
    m.model_code = model[:model_code]
    m.active = true
  end
end

puts "Seed complete!"
puts "Admin login: admin@bydtechassist.com / password123"
