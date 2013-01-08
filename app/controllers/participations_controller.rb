class ParticipationsController < ApplicationController
	include NotificationsHelper
	before_filter :signed_in_user
	# respond_to :html, :js

	def create
		@micropost = Micropost.find(params[:participation][:micropost_id])
		current_user.participate!(@micropost)
		
		#Creating a notification
		creator_id = @micropost.user_id
		message = current_user.name + " has participated in your '" + @micropost.content + "' happpening"
		link = detail_micropost_path(@micropost.id)
		create_notification(creator_id, message, link) 

		redirect_to :back
	end

	def destroy
		@micropost = Participation.find(params[:id]).micropost
		current_user.unparticipate!(@micropost)
		redirect_to :back
		# @user_and_post = [current_user, @micropost]
		# respond_with @user_and_post	
	end
end