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
	
	def add_to_deleted(micropost)
		(session[:to_delete] ||= []) << micropost.id
	end
	
	def retrieve_deleted
		if session[:to_delete]
			temp = (session[:to_delete] || []).dup
			
			session[:to_delete].clear
			
			return temp
		end
		
		return []
	end
end