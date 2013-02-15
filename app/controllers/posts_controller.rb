class PostsController < ApplicationController
  include NotificationsHelper

  #Before Filters
  before_filter :signed_in_user
  before_filter :valid_micropost, only: [:create]
  before_filter :friends_with_creator, only: [:create]
  before_filter :before_create, only: [:create]
  
  before_filter :correct_user, only: :destroy
  
  #After Filters
  after_filter :after_create, only: [:create]

  #Sweepers
  cache_sweeper :event_sweeper, only: [:create, :destroy]
  
  def create
	respond_to do |format|
		format.js
		format.html { redirect_to detail_micropost_path(@post.micropost_id) }
		
		format.mobile do
			json_response = {status: "success"}
  
			render json: json_response
		end
	end
  end

  def destroy
    @post.destroy
    redirect_to :back
  end
  
  #Code to handle ajax pulling requests
  def refresh  
  	@micropost = Micropost.find(params[:id])
  	
  	if @micropost
  		@post_items = @micropost.posts
  		
  		if params[:num].to_i == @post_items.count
  			render text: "cancel"
  		else
  			render partial: 'microposts/post_item', collection: @post_items
  		end
  	end
  end
  
  def mobile_refresh
	logger.debug "mobile refresh checking feed latest: #{session[:feed_latest]}"
  
	@micropost = current_user.feed.find(params[:micropost_id])
	
	if @micropost
		@post_updates = @micropost.posts
		
		updates = []
		
		@post_updates.each do |update|
			updates << update.to_mobile
		end
		
		json_response = {status: "success", replies_data: updates}
		
		render json: json_response
	else	
		json_response = {status: "failure", replies_data: []}
		
		render json: json_response
	end
  end

  private

  def correct_user
    @post = current_user.posts.find_by_id(params[:id])
    redirect_to root_url if @post.nil?
  end
  
  def valid_micropost
	@micropost = Micropost.find_by_id(params[:post][:micropost_id])
	
	if !@micropost
		respond_to do |format|
			format.html { redirect_to root_url, flash: {error: "That is not a valid happening to post to" } }
			format.mobile { render json: {status: "failure", failure_reason: "INVALID_MICROPOST"} }
		end
	end
  end
  
  def friends_with_creator
	if !current_user.friends?(@micropost.user)
		respond_to do |format|
			format.html { redirect_to root_url, flash: {error: "You must be friends with that user to post in that happening"} }
			format.mobile { render json: {status: "failure", failure_reason: "NOT_FRIENDS"} }
		end
	end
  end
  
  #BEFORE FILTER - filters to perform the actual creation that is common across all platform
  def before_create
	@post = current_user.posts.create(params[:post])
	
	if !@post.save
		respond_to do |format|
			format.js
			format.html { redirect_to detail_micropost_path(@post.micropost_id), flash: {error: 'Post can not be empty'} }
			
			format.mobile do
				json_response = {status: "failure"}
	  
				render json: json_response
			end
		end
	end
  end
  
  #AFTER FILTER - filters to send the correct notifications and other clean up duties after creation
  def after_create
	  #Creates internal notifications for all the participants in the event
	  event_post(@micropost)
	  
	  if !current_user.participating?(@micropost)
		current_user.participate(@micropost)
	  end
  end
end