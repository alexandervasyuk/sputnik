class UserMailer < ActionMailer::Base
  def signed_up(user)
    @user = user
    mail(to: user.email, from: "\"Happening\" <notification@happpening.com>", subject: "Welcome to Happening")
  end
end
