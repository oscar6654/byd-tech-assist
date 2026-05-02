class ApplicationMailer < ActionMailer::Base
  default from: -> { SystemSetting.get("default_from_email", "noreply@valuesalesinc.com") }
  layout "mailer"
end
