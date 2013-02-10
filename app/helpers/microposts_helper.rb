module MicropostsHelper
	def update_micropost(micropost)
		if micropost.present?
			micropost.participations.each do |participant|
				MicropostMailer.delay.changed(micropost, participant)
				updated_notification(micropost, participant)
			end
		end
	end
  
    def updated_notification(micropost, participant)
		if micropost.present? && participant.present?
			participant_id = participant.id
			message = micropost.user.name + " has changed the details of '" + micropost.content + "'"
			link = detail_micropost_path(micropost.id)
		
			create_notification(participant_id, message, link)
		end
    end
	
	def mobile_detail_convert(post)
		if post.present?
			replier = post.user
			
			{replier_id: replier.id, replier_picture: replier.avatar.url, reply_text: post.content, replier_name: replier.name, posted_time: post.created_at}
		end
	end
end