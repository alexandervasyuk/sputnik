#Controller that deals with redirecting a user to the correct page on an invite
class InvitesController < ApplicationController
	
	#Action responsible for redirecting a user to the correct page on an invite
	#Expected behaviors:
	#1) If the invitation is valid and the user is already registered, direct to the event page
	#2) If the invitation is valid and the user is not already registered, direct to the sign up page with the email already filled in
	#3) If the invitation is not valid, direct to the main page
	def invite_redirect
	  	@tempuser = User.find(params[:uid])
	  	@micropost = Micropost.find(params[:eid])
	  	
	  	if !@tempuser.nil? && !@micropost.nil?		
	  		if @tempuser.temp
	  			@temp_email = @tempuser.email
	  			flash[:message] = "Please sign up to see your invitation"
	  			
	  			@user = User.new
	  			render "users/new"
	  		else
	  			redirect_to detail_micropost_path(@micropost.id)
	  		end
	  	else
	  		redirect_to root_url, flash: {error: "Invalid invite"}
	  	end
	end
end