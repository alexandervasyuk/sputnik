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
	
	def is_valid_micropost?(micropost)
		return !micropost.nil?
	end
	
	def check_valid_micropost(micropost)
		if !is_valid_micropost?(micropost)
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "That is an invalid happening" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
				format.js { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
			end
		end
	end
	
	def mobile_micropost_errors(micropost)
		if micropost.errors.include?(:content)
			render json: {status: "failure", failure_reason: "INVALID_CONTENT"}
		elsif micropost.errors.include?(:time)
			render json: {status: "failure", failure_reason: "INVALID_TIME"}
		elsif micropost.errors.include?(:end_time)	
			render json: {status: "failure", failure_reason: "INVALID_END_TIME"}
		end
	end
end