class TestMailer < ApplicationMailer
  def test_email(email)
    mail(to: email, subject: "BYD Tech Assist - Test Email") do |format|
      format.html { render html: "<h2>Test Email</h2><p>Your email configuration is working correctly.</p>".html_safe }
      format.text { render plain: "Test Email\nYour email configuration is working correctly." }
    end
  end
end
