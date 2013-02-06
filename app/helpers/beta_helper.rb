module BetaHelper
	def is_in_beta
		return Rails.configuration.in_beta
	end
end