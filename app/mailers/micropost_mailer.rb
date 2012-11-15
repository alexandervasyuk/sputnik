class MicropostMailer < ActionMailer::Base
  def participated(participant, micropost)
    @participant = participant
    @micropost = micropost
    mail(to: participant.email, from: participant.name + " via Happening <notification@happpening.com>", subject: participant.name + " is now participating in \"" + micropost.content + "\"")
  end
end
