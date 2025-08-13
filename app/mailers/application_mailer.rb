class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "Quizzes <no-reply@localhost>")
  layout "mailer"
end
