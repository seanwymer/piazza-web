class UserMailer < ApplicationMailer

  before_action { @user = params[:user] }

  default to: -> { %("#{@user.name}" <#{@user.email}>) }

  default from: "support@piazza.com"

  layout "mailer"

  def password_reset
    mail subject: t(".subject")
  end
end
