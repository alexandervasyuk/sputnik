class PollsController < ApplicationController
	
	before_filter :signed_in_user
	before_filter :valid_micropost
	before_filter :friends_with_creator
	
	protect_from_forgery
	
	def create
		@micropost = Micropost.find(params[:poll][:micropost_id])
		
		@poll = @micropost.polls.build(params[:poll])
		@poll.save
			
		respond_to do |format|
			format.html { redirect_to :back }
			format.mobile { render json: {status: "success", failure_reason: "" } } 
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
	
	private
	
	def valid_micropost
		@micropost = Micropost.find_by_id(params[:poll][:micropost_id])
		
		if !@micropost
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a poll on that micropost" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
				format.js { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
			end
		end
	end
	
	def friends_with_creator
		if !@micropost || (@micropost && !@micropost.user) || (@micropost && @micropost.user && !current_user.friends?(@micropost.user))
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a poll on this happening, please friend the creator first" } }
				format.mobile { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
				format.js { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
			end
		end
	end
end