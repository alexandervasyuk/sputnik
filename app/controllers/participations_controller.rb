class ParticipationsController < ApplicationController
	before_filter :signed_in_user
	respond_to :html, :js

	def create
		@micropost = Micropost.find(params[:participation][:micropost_id])
		current_user.participate!(@micropost)
		
		#Send the email out
		MicropostMailer.participated(current_user, @micropost).deliver
		
		@user_and_post = [current_user, @micropost]
		respond_with @user_and_post
	end

	def destroy
		@micropost = Participation.find(params[:id]).micropost
		current_user.unparticipate!(@micropost)
		@user_and_post = [current_user, @micropost]
		respond_with @user_and_post	
	end
end