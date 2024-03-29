require 'socket'

class MicropostMailer < ActionMailer::Base
  def participated(participant, micropost)
    @participant = participant
    @micropost = micropost
    
    return mail(to: micropost.user.email, from: participant.name + " via Happpening <notification@happpening.com>", subject: participant.name + " is now participating in \"" + micropost.content + "\"")
  end
  
  def replied(post)
    @post = post
    @creator = post.micropost.user
    @poster = post.user
    return mail(to: @creator.email, from: @poster.name + " via Happpening <notification@happpening.com>", subject: @poster.name + " has replied to \"" + post.micropost.content + "\"")
  end
  
  def changed(micropost, participant)
    @micropost = micropost
    @creator = @micropost.user

	return mail(to: participant.user.email, from: @creator.name + " via Happpening <notification@happpening.com>", subject: @creator.name + " has changed the details of \"" + @micropost.content + "\"")
  end
  
  def invited(micropost, user)
  	@micropost = micropost
  	@user = user
  	@inviter = @micropost.user

  	return mail(to: @user.email, from: @inviter.name + " via Happpening <notification@happpening.com>", subject: @inviter.name + " has invited you to \"" + @micropost.content + "\"")
  end
  
  def email_invited(micropost, user, protocol, host, port)
  	@micropost = micropost
  	@creator = @micropost.user
  	@user = user
  	@protocol = protocol
  	@host = host
  	@port = port
  	
  	return mail(to: user.email, from: @creator.name + " via Happpening <notification@happpening.com>", subject: @creator.name + " has invited you to participate in \"" + @micropost.content + "\"")
  end
end
