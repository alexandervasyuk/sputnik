class ProposalsController < ApplicationController
	include TimeHelper

	before_filter :time_input_parser, only: :create
	
	def create
		@proposal = current_user.proposals.build(params[:proposal])
		@proposal.save
		
		redirect_to detail_micropost_path(params[:proposal][:micropost_id])
	end
	
	def update
	
	end
	
	def destroy
	
	end
	
	private
	
	def time_input_parser
		params[:proposal][:time] = parse_time(params[:proposal][:time])
	end
end