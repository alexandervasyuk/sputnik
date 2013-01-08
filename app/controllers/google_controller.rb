class GoogleController < ApplicationController
	def places_autocomplete
		options = {name: params[:name], key: 'AIzaSyBLJ6U6btyk5WgBPoSf8VJDe3LZsPI9NYs'}
		
		render json: place_search(options)
	end
end