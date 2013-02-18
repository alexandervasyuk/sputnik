class CharacteristicsAppsController < ApplicationController
	before_filter :signed_in_user
	
	before_filter :before_create, only: [:create]
	before_filter :before_destroy, only: [:destroy]
	
	before_filter :valid_micropost, only: [:create, :destroy]
	before_filter :characteristics_app_exists, only: [:create]
	before_filter :friends_with_creator, only: [:create, :destroy]
	before_filter :participating_in_micropost, only: [:create, :destroy]
	
	def create
		CharacteristicsApp.create(params[:characteristics_app])
		
		respond_to do |format|
			format.html { redirect_to :back }
			format.mobile { render json: {status: "success"} }
		end
	end
	
	def destroy
		@characteristics_app.destroy
		
		respond_to do |format|
			format.html { redirect_to :back }
			format.mobile { render json: {status: "success"} }
		end
	end
	
	private
	
	def before_create
		@micropost = Micropost.find_by_id(params[:characteristics_app][:micropost_id])
	end
	
	def before_destroy
		@characteristics_app = CharacteristicsApp.find_by_id(params[:id])
		
		check_valid_characteristics_app(@characteristics_app)
		
		if @characteristics_app
			@micropost = @characteristics_app.micropost
		end
	end
	
	def valid_micropost
		check_valid_micropost(@micropost)
	end
	
	def characteristics_app_exists
		check_characteristics_app_exists(@micropost.characteristics_app(true))
	end
	
	def friends_with_creator
		check_friends_with_creator(@micropost.user.friends?(current_user))
	end
	
	def participating_in_micropost
		check_participating_in(@micropost)
	end
end