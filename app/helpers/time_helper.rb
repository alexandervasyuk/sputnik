module TimeHelper
	# Function that converts a user generated string into a time, using libraries that supports those input types
	def parse_time(time_string)
		if time_string.present?
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
	
	def parse_start_time(time_string)
		converted_time = parse_time(time_string)
		
		if (time_string != "" && time_string != nil) && converted_time.nil?
			respond_to do |format|
				format.html { redirect_to :back, flash: {error: "Invalid start time"} }
				format.mobile { render json: {status: "failure", failure_reason: "TIME_FORMAT"} }
				format.js { }
			end
		end
		
		return converted_time
	end
	
	def parse_end_time(time_string)
		converted_time = parse_time(time_string)
		
		if (time_string != "" && time_string != nil) && converted_time.nil?
			respond_to do |format|
				format.html { redirect_to :back, flash: {error: "Invalid end time"} }
				format.mobile { render json: {status: "failure", failure_reason: "END_TIME_FORMAT"} }
				format.js { }
			end
		end
		
		return converted_time
	end
	
	def time_representation(start_time, end_time)
		if start_time.present? && end_time.present?
			start_time_string = start_time.in_time_zone(user_timezone).strftime('%l:%M%p')
			end_time_string = end_time.in_time_zone(user_timezone).strftime('%l:%M%p')
		
			if start_time.day == end_time.day && start_time.month == end_time.month && start_time.year == end_time.year			
				if is_today(start_time)
					return start_time_string + " - " + end_time_string + " Today"
				elsif is_tomorrow(start_time)
					return start_time_string + " - " + end_time_string + " Tomorrow"
				else
					return start_time_string + " - " + end_time_string + " " + date_format(start_time)
				end
			else
				return_string = start_time_string
				
				if is_today(start_time)
					return_string += " Today "
				elsif is_tomorrow(start_time)
					return_string += " Tomorrow "
				else	
					return_string += " " + date_format(start_time) + " "
				end
				
				return_string += " - " + end_time_string
				
				if is_today(end_time)
					return_string += " Today"
				elsif is_tomorrow(end_time)
					return_string += " Tomorrow"
				else
					return_string += " " + date_format(end_time)
				end
				
				return return_string
			end
		elsif start_time && !end_time
			start_time_string = start_time.in_time_zone(user_timezone).strftime('%l:%M%p')
		
			if is_today(start_time)
				return start_time_string + " Today"
			elsif is_tomorrow(start_time)
				return start_time_string + " Tomorrow"
			else
				return start_time_string + " " + date_format(start_time)
			end
		elsif !start_time && !end_time	
			return "Not Set"
		end
	end
	
	def date_format(time)
		time.in_time_zone(user_timezone).strftime('%b %e')
	end
	
	def is_today(time)
		Time.use_zone(user_timezone) do 
			today_time = Time.current()
		
			today_time.day == time.day && today_time.month == time.month && today_time.year == time.year
		end
	end
	
	def is_tomorrow(time)
		Time.use_zone(user_timezone) do
			Time.current().beginning_of_day.tomorrow < time.in_time_zone(user_timezone) and time.in_time_zone(user_timezone) < Time.current().beginning_of_day.advance(days: 2)
		end
	end
end