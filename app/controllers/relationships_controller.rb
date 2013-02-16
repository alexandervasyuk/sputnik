class RelationshipsController < ApplicationController  
  before_filter :signed_in_user

  before_filter :before_create, only: [:create]
  before_filter :before_update, only: [:update]
  before_filter :before_destroy, only: [:destroy]
  
  after_filter :after_create, only: [:create]
  after_filter :after_update, only: [:update]

  def create
    @created = current_user.friend_request(@friend_requested)
	
	respond_to do |format|
		format.html
		format.js
		format.mobile { render json: {status: "success"} }
	end
  end
  
  def update
    if params[:type] == 'ACCEPT'
      @updated = current_user.accept_friend(@friend_requester)
	  
	  respond_to do |format|
		format.html { redirect_to :back }
		format.js
		format.mobile { render json: {status: "success"} }
	  end
    elsif params[:type] == 'IGNORE'
	  @updated = current_user.ignore(@friend_requester)
	
      respond_to do |format|
		format.html { redirect_to :back }
		format.js
		format.mobile { render json: {status: "success"} }
      end
	end
  end

  def destroy
	@destroyed = @relationship.destroy
	
	respond_to do |format|
		format.html { redirect_to :back }
		format.js
		format.mobile { render json: {status: "success"} }
	end
  end
  
  def mobile_destroy
	@user = User.find(params[:id])
	
	if @user
		relationship = @user.get_relationship(current_user)
		
		if relationship
			relationship.destroy
			render json: {status: "success"}
		else		
			render json: {status: "failure"}
		end
	else
		render json: {status: "failure"}
	end
  end
  
  private
  
  def before_create
	@friend_requested = User.find_by_id(params[:requested_id]) || User.find_by_id(params[:relationship][:followed_id])
	@relationship = current_user.get_relationship(@friend_requested)
	
	if @relationship.present?
		respond_to do |format|
			format.html
			format.js
			format.mobile { render json: {status: "failure", failure_reason: "RELATIONSHIP_EXISTS"} }
		end
	end
  end
  
  def before_update
	@friend_requester = User.find_by_id(params[:requester_id]) || User.find_by_id(params[:relationship][:follower_id])
	
	if !@friend_requester.pending?(current_user)
		respond_to do |format|
			format.html
			format.js
			format.mobile { render json: {status: "failure", failure_reason: "NO_FRIEND_REQUEST"} }
		end
	end
  end
  
  def before_destroy
	if params[:friend_id]
		@friend = User.find_by_id(params[:friend_id])
		
		if !@friend.friends?(current_user)
			respond_to do |format|
				format.html
				format.js
				format.mobile { render json: {status: "failure", failure_reason: "NOT_FRIENDS"} }
			end
		else	
			@relationship = current_user.get_relationship(@friend)
		end
	else
		@relationship = Relationship.find(params[:id])
	end
  end
  
  def after_create
	if @created
		#Create notification
		creator_id = @friend_requested.id
		message = current_user.name + " has requested your friendship"
		link = '/friend'
		create_notification(creator_id, message, link) 

		UserMailer.delay.friend_requested(current_user, @friend_requested)
	end
  end
  
  def after_update
	 if @updated
		if params[:type] == "ACCEPT"
			creator_id = @friend_requester.id
			message = current_user.name + " has accepted your friendship"
			link = '/friend'
			create_notification(creator_id, message, link)
		end
	end
  end
end