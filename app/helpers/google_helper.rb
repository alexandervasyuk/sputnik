module GoogleHelper
	def place_search(options)
		Rails.cache.fetch("#{convert_options(options)}", expires_in: 24.hours) do
			uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json" + convert_options(options))
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			
			request = Net::HTTP::Get.new(uri.request_uri)
			
			response = http.request(request)
			
			#Updating the user's cache of search results, will include 
			gcaches = current_user.gcaches
			
			json_response = JSON.parse(response.body)
			
			json_response["results"].each do |result|
				current_gcache = gcaches.where("latitude = :latitude AND longitude = :longitude AND name = :name AND address = :address", {latitude: result["geometry"]["location"]["lat"], longitude: result["geometry"]["location"]["lng"], name: result["name"], address: result["formatted_address"]})[0]
				current_gcache ||= gcaches.create(latitude: result["geometry"]["location"]["lat"].to_f, longitude: result["geometry"]["location"]["lng"].to_f, name: result["name"], address: result["formatted_address"])

				current_gcache.save
			end
			
			response.body
		end
	end
	
	def convert_options(options)
		latitude = current_location[:latitude].to_f
		longitude = current_location[:longitude].to_f
	
		if latitude == 0.0 && longitude == 0.0
			latitude = 37.867868 
			longitude = -122.260797
		end
	
		return "?name=#{options[:name].gsub(" ", "+")}&sensor=false&key=#{options[:key]}&radius=50000&location=#{latitude},#{longitude}"
	end
end