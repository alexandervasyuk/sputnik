class ProposalsController < ApplicationController
	include TimeHelper

	#Before Filters
	before_filter :time_input_parser, only: [:create, :update]
	
	#Sweepers
	cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
	
	def create
		@proposal = current_user.proposals.build(params[:proposal])
		@proposal.users << current_user
		@proposal.save
		
		respond_to do |format|
			format.js 
			format.html { redirect_to detail_micropost_path(params[:proposal][:micropost_id]) }
		end
	end
	
	def update
		@proposal = Proposal.find(params[:id])
		
		Rails.logger.debug "params[:id] = #{params[:id]}"
		
		Rails.logger.debug "Proposal: #{@proposal.id}, #{@proposal.content}"
		Rails.logger.debug "Proposal users: #{@proposal.users.all}"
		
		if @proposal.users.all.include? current_user
			Rails.logger.debug "deleting current user"
			@proposal.users.delete current_user
		else
			Rails.logger.debug "adding current user"
			@proposal.users << current_user
		end
		
		@proposal.save
		
		respond_to do |format|
			format.js
			format.html { redirect_to detail_micropost_path(params[:proposal][:micropost_id]) }
		end
	end
	
	def destroy
	
	end
	
	private
	
	def time_input_parser
		params[:proposal][:time] = parse_time(params[:proposal][:time])
		params[:proposal][:end_time] = parse_time(params[:proposal][:end_time])
	end
end