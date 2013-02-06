module GoogleHelper
	def google_place_search(options, current_location)
		# Google Search
		uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json" + convert_options_for_place_search(options, current_location))
		
		response = $http.request uri
		
		return JSON.parse(response.body)["results"]
	end
	
	def google_autocomplete_search(options, current_location)
		# Google Search
		uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json" + convert_options_for_autocomplete_search(options, current_location))
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		
		request = Net::HTTP::Get.new(uri.request_uri)
		
		response = http.request(request)
		
		return JSON.parse(response.body)["predictions"]
	end

	def place_search(options, current_location, current_user)
		if current_location[:latitude] != 0.0 && current_location[:longitude] != 0.0 && current_user
			
			#One time
			if current_user.gcaches.where("search_latitude = :search_latitude AND search_longitude = :search_longitude AND term = :term", {search_latitude: round(current_location[:latitude], 3), search_longitude: round(current_location[:longitude], 3), term: options[:name]}).count == 0
				
				#One time
				cached_results = Gcach.where("search_latitude = :search_latitude AND search_longitude = :search_longitude AND term = :term", {search_latitude: round(current_location[:latitude], 3), search_longitude: round(current_location[:longitude], 3), term: options[:name]})
				
				relationships_to_insert = []
				
				if cached_results.count == 0
					json_response = google_place_search(options, current_location)
					
					gcaches_to_insert = []
					
					json_response.each do |result|
						#Looped
						gcaches_to_insert += index_term(options[:name], convert_to_hash(result), current_location, current_user)
					end
					
					Gcach.import gcaches_to_insert
					
					add_relationships(options[:name], current_user)
				else
					cached_results.each do |cached_result|
						relationship = cached_result.user_gcaches.build(user_id: current_user.id)
						
						relationships_to_insert << relationship
					end
				end
				
				UserGcach.import relationships_to_insert
			end
			
			return retrieve_object(options[:name], round(current_location[:latitude], 3), round(current_location[:longitude], 3), current_user)
		else
			return nil
		end
	end
	
	def convert_to_hash(google_location)
		return {name: google_location["name"], latitude: google_location["geometry"]["location"]["lat"], longitude: google_location["geometry"]["location"]["lng"], address: google_location["vicinity"]}
	end
	
	def add_relationships(term, current_user)
		relationships_to_insert = []
		terms = []
	
		3.upto(term.length) do |n|
			terms << term[0, n]
		end
		
		gcaches_for_relationships = Gcach.where("term in (:terms)", {terms: terms})
		
		gcaches_for_relationships.each do |gcach_for_relationship|
			relationships_to_insert << gcach_for_relationship.user_gcaches.build(user_id: current_user.id)
		end
		
		UserGcach.import relationships_to_insert
	end
	
	def index_term(term, object, current_location, current_user)
		latitude_difference = current_location[:latitude] - object[:latitude].to_f
		longitude_difference = current_location[:longitude] - object[:longitude].to_f
			
		rank = Math.sqrt(latitude_difference * latitude_difference + longitude_difference * longitude_difference)
		
		gcaches_to_insert = []
		
		3.upto(term.length) do |n|
			#Super loop
			prefix = term[0, n]
			
			gcach = Gcach.new
		
			gcach.search_latitude = round(current_location[:latitude], 3)
			gcach.search_longitude = round(current_location[:longitude], 3)
			gcach.term = prefix
			gcach.name = object[:name]
			gcach.latitude = object[:latitude]
			gcach.longitude = object[:longitude]
			gcach.address = object[:address]
			
			gcach.rank = rank
			
			gcaches_to_insert << gcach
		end
		
		return gcaches_to_insert
	end
	
	def round(number, sigfigs)
		return (number * (10 ** sigfigs).to_f).round / (10 ** sigfigs).to_f
	end
	  
	def retrieve_object(term, latitude, longitude, current_user)
		#One time
		current_user.gcaches.where("term = :term AND search_latitude = :search_latitude AND search_longitude = :search_longitude", {term: term, search_latitude: latitude, search_longitude: longitude}).order("rank ASC").limit(5)
	end
	
	def convert_options_for_place_search(options, current_location)
		latitude = current_location[:latitude]
		longitude = current_location[:longitude]
	
		return "?name=#{options[:name].gsub(" ", "+")}&sensor=false&key=#{options[:key]}&radius=50000&location=#{latitude},#{longitude}"
	end
	
	def convert_options_for_autocomplete_search(options, current_location)
		latitude = current_location[:latitude]
		longitude = current_location[:longitude]
		
		return "?input=#{options[:name].gsub(" ", "+")}&sensor=false&key=#{options[:key]}&radius=50000&location=#{latitude},#{longitude}"
	end
end