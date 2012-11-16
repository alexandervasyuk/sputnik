class ParticipationsController < ApplicationController
	before_filter :signed_in_user
	# respond_to :html, :js

	def create
		@micropost = Micropost.find(params[:participation][:micropost_id])
		current_user.participate!(@micropost)
		
		#Send the email out
		#MicropostMailer.participated(@micropost.user, @micropost).deliver

		redirect_to :back
		# @user_and_post = [current_user, @micropost]
		# respond_with @user_and_post
	end

	def destroy
		@micropost = Participation.find(params[:id]).micropost
		current_user.unparticipate!(@micropost)
		redirect_to :back
		# @user_and_post = [current_user, @micropost]
		# respond_with @user_and_post	
	end
end