class MicropostMailer < ActionMailer::Base
  default from: "bochen303@gmail.com"
  
  def participated(participant, micropost)
    @participant = participant
    @micropost = micropost
    mail(to: participant.email, subject: "thanks for participating motherfucka")
  end
end
