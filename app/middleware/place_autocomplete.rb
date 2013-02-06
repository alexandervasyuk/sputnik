class PlaceAutocomplete
	include SessionsHelper
	include GoogleHelper

	def initialize(app)
		@app = app
	end
	
	def call(env)
		if env["PATH_INFO"] == "/google/places/autocomplete"
			request = Rack::Request.new(env)
			
			result = place_search({name: request.params["name"], key: 'AIzaSyBLJ6U6btyk5WgBPoSf8VJDe3LZsPI9NYs'}, {latitude: env['rack.request.cookie_hash']["latitude"].to_f, longitude: env['rack.request.cookie_hash']["longitude"].to_f}, User.find_by_remember_token(env['rack.request.cookie_hash']["remember_token"]))
			
			[200, {"Content-Type" => "application/json"}, [result.to_json]]
		else
			@app.call(env)
		end
	end
end