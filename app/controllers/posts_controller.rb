class PostsController < ApplicationController
  include NotificationsHelper

  before_filter :signed_in_user
  before_filter :correct_user, only: :destroy
  
  before_filter :before_create, only: [:create, :create_mobile]
  after_filter :after_create, only: [:create, :create_mobile]

  def create
    if !@created
      flash[:error] = 'Post can not be empty'
      @post_items = []
	end
	
	redirect_to detail_micropost_path(@post.micropost_id)
  end
  
  def create_mobile
	if @created
	  json_response = {status: "success"}
	  
	  render json: json_response
	else
	  json_response = {status: "failure"}
	  
	  render json: json_response
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
  
  #BEFORE FILTER - filters to perform the actual creation that is common across all platform
  def before_create
	@post = current_user.posts.create(params[:post])
	
	@created = @post.save
  end
  
  #AFTER FILTER - filters to send the correct notifications and other clean up duties after creation
  def after_create
	if @created
	  #Creates internal notifications for all the participants in the event
      event_post(@post.micropost) 
	end
  end
end