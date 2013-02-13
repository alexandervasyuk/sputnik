class PollsController < ApplicationController
	before_filter :signed_in_user
	
	protect_from_forgery
	
	def create
		@micropost = Micropost.find(params[:poll][:micropost_id])
		
		@poll = @micropost.polls.build(params[:poll])
		@poll.save
			
		respond_to do |format|
			format.html { redirect_to :back }
			format.js
		end
	end
	
	def update
	
	end
	
	def destroy
		@poll = Poll.find(params[:id])
		
		@poll.destroy
		
		respond_to do |format|
			format.html { redirect_to :back }
			format.js
		end
	end
end