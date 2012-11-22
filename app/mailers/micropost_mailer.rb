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
end
