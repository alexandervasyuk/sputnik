class InvitesController < ApplicationController
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