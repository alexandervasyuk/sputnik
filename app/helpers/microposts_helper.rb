module MicropostsHelper
	def update_micropost(micropost)
		micropost.non_creator_participants.each do |participant|
  			MicropostMailer.delay.changed(micropost, participant)
  			updated_notification(micropost, participant)
		end
	end
  
    def updated_notification(micropost, participant)
  		participant_id = participant.id
  		message = micropost.user.name + " has changed the details of '" + micropost.content + "'"
  		link = detail_micropost_path(micropost.id)
  	
  		create_notification(participant_id, message, link)
    end
	
	def mobile_detail_convert(post)
		replier = post.user
		
		return {replier_id: replier.id, replier_picture: replier.avatar.url, reply_text: post.content, replier_name: replier.name, posted_time: post.created_at}
	end
end