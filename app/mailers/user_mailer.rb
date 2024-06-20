class UserMailer < ApplicationMailer

  before_action { @user = params[:user] }

  default to: -> { %("#{@user.name}" <#{@user.email}>) }

  default from: "support@piazza.com"

  layout "mailer"

  def password_reset(token)
    @password_reset_token = token

    mail subject: t(".subject")
  end
end
