module ProposalsHelper
	def count_location_proposals(micropost, location)
		micropost.proposals.where("location = :location", {location: location}).count
	end
	
	def count_time_proposals(micropost, time)
		micropost.proposals.where("time = :time", {time: time}).count
	end
	
	def is_valid_proposal?(proposal)
		!proposal.nil?
	end
	
	def check_valid_proposal(proposal)
		if !is_valid_proposal?(proposal)
			respond_to do |format|
				format.html { redirect_to :back, flash: {error: "That is not a valid proposal"} }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_PROPOSAL"} }
				format.js { }
			end
		end
	end
end