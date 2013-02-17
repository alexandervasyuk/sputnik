class CharacteristicsAppsController < ApplicationController
	before_filter :signed_in_user
	
	before_filter :before_create, only: [:create]
	before_filter :before_destroy, only: [:destroy]
	
	before_filter :friends_with_creator, only: [:create, :destroy]
	before_filter :participating_in_micropost, only: [:create, :destroy]
	
	def create
		
	end
	
	def destroy
	
	end
	
	private
	
	def before_create
		@micropost = Micropost.find(params[:characteristics_app][:micropost_id])
	end
	
	def before_destroy
		@characteristics_app = CharacteristicsApp.find(params[:id])
		@micropost = @characteristics_app.micropost
	end
	
	def friends_with_creator
		check_friends_with_creator(@micropost.user.friends?(current_user))
	end
	
	def participating_in_micropost
		check_participating_in(@micropost)
	end
end