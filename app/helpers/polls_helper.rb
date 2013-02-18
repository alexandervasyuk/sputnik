module PollsHelper
	def is_valid_poll?(poll)
		return !poll.nil?
	end
	
	def check_valid_poll(poll)
		if !is_valid_poll?(poll)
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a proposal to that poll" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_POLL"} }
			end
		end
	end
end