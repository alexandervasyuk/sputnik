class MailingJob < Struct.new(:mail)
  
  def perform
    mail.deliver
  end
end