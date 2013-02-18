class ProposalsController < ApplicationController
	include TimeHelper

	#Before Filters
	before_filter :signed_in_user
	
	before_filter :create_prepare, only: [:create]
	before_filter :update_prepare, only: [:update]
	
	before_filter :valid_poll
	before_filter :friends_with_creator
	before_filter :time_input_parser, only: [:create]
	before_filter :proposal_exists, only: [:create]
	before_filter :creator_user, only: [:delete]
	
	after_filter :participating_user, only: [:create, :update]
	#Sweepers
	cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
	
	def create
		@proposal ||= current_user.proposals.build(params[:proposal])
		@proposal.users << current_user
		@proposal.save
		
		respond_to do |format|
			format.js	
			format.mobile { render json: {status: "success", failure_reason: "", poll: @proposal.poll.to_mobile} }
			format.html { redirect_to detail_micropost_path(@proposal.poll.micropost) }
		end
	end
	
	def update
		@proposal.toggle_user(current_user)
		
		respond_to do |format|
			format.js
			format.html { redirect_to detail_micropost_path(@proposal.poll.micropost) }
			format.mobile { render json: {status: "success"} }
		end
	end
	
	def destroy
		
	end
	
	private
	
	# BEFORE FILTER - does initial check for the inputs on the create action to make sure they're kosher
	def create_prepare
		@poll = Poll.find_by_id(params[:proposal][:poll_id])
	end
	
	# BEFORE FILTER - does initial check for the inputs on the update action to make sure they're kosher
	def update_prepare
		@proposal = Proposal.find_by_id(params[:id])
		
		check_valid_proposal(@proposal)
		
		if is_valid_proposal?(@proposal)
			@poll = @proposal.poll
		end
	end
	
	def time_input_parser
		params[:proposal][:time] = parse_time(params[:proposal][:time])
		params[:proposal][:end_time] = parse_time(params[:proposal][:end_time])
	end
	
	# BEFORE FILTER - checks if the poll the user is trying to make a proposal to is valid
	def valid_poll
		check_valid_poll(@poll)
		
		if is_valid_poll?(@poll)
			@micropost = @poll.micropost
		end
	end
	
	def friends_with_creator
		check_friends_with_creator(current_user.friends?(@micropost.user))
	end
	
	# BEFORE FILTER - checks if the proposal the user is trying to make already exists
	def proposal_exists
		time_placeholder = params[:proposal][:time].nil? ? "IS NULL" : " = :time"		
		end_time_placeholder = params[:proposal][:time].nil? ? "IS NULL" : " = :end_time"
	
		@proposal = @poll.proposals.where("content = :content AND (time #{time_placeholder} AND end_time #{end_time_placeholder}) AND location = :location", {content: params[:proposal][:content], location: params[:proposal][:location], time: params[:proposal][:time], end_time: params[:proposal][:end_time]})[0]
	end
	
	def creator_user
		
	end
	
	# AFTER FILTER - checks if the user is participating in the micropost they are trying to make a proposal to
	def participating_user
		if @micropost && !current_user.participating?(@micropost)
			current_user.participate(@micropost)
		end
	end
end