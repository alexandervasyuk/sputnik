class UserMailer < ActionMailer::Base
  def signed_up(user)
    @user = user
    mail(to: user.email, from: "\"Happpening\" <notification@happpening.com>", subject: "Welcome to Happpening")
  end
  
  def friend_requested(requester, requestee)
    @requester = requester
    @requestee = requestee
    
    mail(to: @requestee.email, from: @requester.name + " via Happening <notification@happpening.com>", subject: "Friend request from " + @requester.name)
  end
  
  def friend_accepted(requester, requestee)
    @requester = requester
    @requestee = requestee
    
    mail(to: @requester.email, from: @requestee.name + " via Happening <notification@happpening.com>", subject: @requestee.name + " has accepted your friend request")
  end
  
  def password_reset(user)
    @user = user
    mail(to: @user.email, from: "Happening <notification@happpening.com>", subject: "Password Reset")
  end
end
