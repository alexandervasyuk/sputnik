class PostsController < ApplicationController
  include NotificationsHelper

  #Before Filters
  before_filter :signed_in_user
  before_filter :valid_micropost, only: [:create, :refresh]
  before_filter :friends_with_creator, only: [:create, :refresh]
  before_filter :before_create, only: [:create]
  
  before_filter :correct_user, only: :destroy
  
  #After Filters
  after_filter :after_create, only: [:create]
  after_filter :after_destroy, only: [:destroy]
  after_filter :after_refresh, only: [:refresh]

  #Sweepers
  cache_sweeper :event_sweeper, only: [:create, :destroy]
  
  def create
	respond_to do |format|
		format.js
		format.html { redirect_to detail_micropost_path(@post.micropost_id) }
		
		format.mobile do
			json_response = {status: "success", post: @post.to_mobile}
  
			render json: json_response
		end
	end
  end

  def destroy
    @post.destroy
	
	respond_to do |format|
		format.html { redirect_to :back }
		format.mobile { render json: {status: "success"} }
	end
  end
  
  #Code to handle ajax pulling requests
  def refresh
		@post_items = get_later_posts(@micropost)
		@mobile_post_items = @post_items.collect { |post_item| post_item.to_mobile }
		
		respond_to do |format|
			format.html { render partial: 'microposts/post_item', collection: @post_items }
			format.mobile { render json: {status: "success", replies: @mobile_post_items, to_delete: retrieve_deleted_posts} }
		end
  end

  private

  def correct_user
	@post = current_user.posts.find_by_id(params[:id])
	
    if @post.nil?
		respond_to do |format|
			format.html { redirect_to root_url, flash: {error: "You must own the post to delete it"} }
			
			format.mobile { render json: {status: "failure", failure_reason: "NOT_OWNER"} }
		end
	end
  end
  
  def valid_micropost
	@micropost = Micropost.find_by_id(params[:micropost_id] || params[:post][:micropost_id])
	
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
	  
	  set_latest_post(@micropost, @post)
  end
  
  def after_destroy
	add_deleted_post(@post)
  end
  
  def after_refresh
	set_latest_post(@micropost, @post_items.first)
  end
end