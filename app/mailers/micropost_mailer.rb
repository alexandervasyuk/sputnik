class MicropostMailer < ActionMailer::Base
  def participated(participant, micropost)
    @participant = participant
    @micropost = micropost
    return mail(to: micropost.user.email, from: participant.name + " via Happening <notification@happpening.com>", subject: participant.name + " is now participating in \"" + micropost.content + "\"")
  end
  
  def replied(post)
    @post = post
    @creator = post.micropost.user
    @poster = post.user
    return mail(to: @creator.email, from: @poster.name + " via Happening <notification@happpening.com>", subject: @poster.name + " has replied to \"" + post.micropost.content + "\"")
  end
  
  def changed(micropost)
    @micropost = micropost
    @creator = @micropost.user
    @participations = @micropost.participations
    
    mails = []
    
    @participations.each do |participation|
      participant = participation.user
      
      if participant.email != @creator.email
        mails << mail(to: participant.email, from: @creator.name + " via Happening <notification@happpening.com>", subject: @creator.name + " has changed the details of \"" + @micropost.content + "\"")
      end
    end
    
    return mails
  end
end
