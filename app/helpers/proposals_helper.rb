module ProposalsHelper
	def count_location_proposals(micropost, location)
		micropost.proposals.where("location = :location", {location: location}).count
	end
	
	def count_time_proposals(micropost, time)
		micropost.proposals.where("time = :time", {time: time}).count
	end
end