class ProposalsController < ApplicationController
	include TimeHelper

	#Before Filters
	before_filter :time_input_parser, only: [:create, :update]
	before_filter :signed_in_user
	before_filter :valid_poll
	before_filter :friends_with_creator
	before_filter :participating_user, only: [:create, :update]
	before_filter :proposal_exists, only: [:create]
	before_filter :creator_user, only: [:delete]
	
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
		@proposal = Proposal.find(params[:id])
		
		if @proposal.users.all.include? current_user
			@proposal.users.delete current_user
		else
			@proposal.users << current_user
		end
		
		@proposal.save
		
		respond_to do |format|
			format.js
			format.html { redirect_to detail_micropost_path(@proposal.poll.micropost) }
		end
	end
	
	def destroy
	
	end
	
	private
	
	def time_input_parser
		params[:proposal][:time] = parse_time(params[:proposal][:time])
		params[:proposal][:end_time] = parse_time(params[:proposal][:end_time])
	end
	
	# BEFORE FILTER - checks if the poll the user is trying to make a proposal to is valid
	def valid_poll
		@poll = Poll.find_by_id(params[:proposal][:poll_id])
		
		if !@poll
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a proposal to that poll" } }
				format.mobile { render json: {status: "failure", failure_reason: "INVALID_POLL"} }
			end
		end
	end
	
	def friends_with_creator
		if !@poll.micropost || (@poll.micropost && !@poll.micropost.user) || (@poll.micropost && @poll.micropost.user && !current_user.friends?(@poll.micropost.user))
			respond_to do |format|
				format.html { redirect_to :back, flash: { error: "Cannot make a proposal to this pool, please friend the creator first" } }
				format.mobile { render json: { status: "failure", failure_reason: "NOT_FRIENDS" } }
			end
		end
	end
	
	# BEFORE FILTER - checks if the user is participating in the micropost they are trying to make a proposal to
	def participating_user
		if @poll.micropost && !current_user.participating?(@poll.micropost)
			current_user.participate(@poll.micropost)
		end
	end
	
	# BEFORE FILTER - checks if the proposal the user is trying to make already exists
	def proposal_exists
		time_placeholder = params[:proposal][:time].blank? ? "IS NULL" : " = :time"		
		end_time_placeholder= params[:proposal][:time].blank? ? "IS NULL" : " = :end_time"
	
		@proposal = @poll.proposals.where("content = :content AND (time #{time_placeholder} AND end_time #{end_time_placeholder}) AND location = :location", {content: params[:proposal][:content], location: params[:proposal][:location], time: params[:proposal][:time], end_time: params[:proposal][:end_time]})[0]
	end
	
	def creator_user
		
	end
end