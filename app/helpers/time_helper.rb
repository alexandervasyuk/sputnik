module TimeHelper
	def parse_time(time_string)
		if time_string[0..1] == "at"
		   #Time parser used
		   Time.use_zone(user_timezone) do
			 return Time.zone.parse(time_string)
		   end
		else
			#Chronic parser used
			Time.use_zone(user_timezone) do
			  Chronic.time_class = Time.zone
			  return Chronic.parse(time_string)
			end
		end
	end
end