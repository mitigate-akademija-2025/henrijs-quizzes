class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", ENV["SMTP_USERNAME"])
  layout "mailer"
end
