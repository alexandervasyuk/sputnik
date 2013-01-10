class ProposalsController < ApplicationController
	include TimeHelper

	#Before Filters
	before_filter :time_input_parser, only: [:create, :update]
	
	#Sweepers
	cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
	
	def create
		@proposal = current_user.proposals.build(params[:proposal])
		@proposal.save
		
		redirect_to detail_micropost_path(params[:proposal][:micropost_id])
	end
	
	def update
		@proposal = Proposal.find(params[:id])
		
		if !params[:proposal][:content].blank?
			@proposal.content = params[:proposal][:content]
		end
		
		if !params[:proposal][:location].blank?
			@proposal.location = params[:proposal][:location]
		end
		
		if !params[:proposal][:time].blank?
			@proposal.time = params[:proposal][:time]
		end
		
		@proposal.save
		
		redirect_to detail_micropost_path(params[:proposal][:micropost_id])
	end
	
	def destroy
	
	end
	
	private
	
	def time_input_parser
		params[:proposal][:time] = parse_time(params[:proposal][:time])
	end
end