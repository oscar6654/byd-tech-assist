class ApplicationMailer < ActionMailer::Base
  default from: -> { SystemSetting.get("default_from_email", "noreply@example.com") }
  layout "mailer"
end
