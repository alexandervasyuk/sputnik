class RelationshipsController < ApplicationController  
  before_filter :signed_in_user

  before_filter :before_create, only: [:create]
  
  after_filter :after_create, only: [:create]
  
  respond_to :html, :js

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
      @user = User.find(params[:relationship][:follower_id])
      current_user.accept_friend(@user)
		  #Create notification
      creator_id = @user.id
      message = current_user.name + " has accepted your friendship"
      link = '/friend'
      create_notification(creator_id, message, link) 

      redirect_to :back
    elsif params[:type] == 'IGNORE'
      relationship = Relationship.find(params[:id])
      relationship.friend_status = "IGNORED"
      relationship.save
      
      redirect_to :back
	end
  end
  
  def mobile_update
	if params[:type] == 'ACCEPT'
		user = User.find(params[:id])
		
		if user
			current_user.accept_friend(user)
			render json: {status: "success"}
		else	
			render json: {status: "failure"}
		end
	elsif params[:type] == 'IGNORE'
		user = User.find(params[:id])
		
		if user
			current_user.ignore(user)
			render json: {status: "success"}
		else
			render json: {status: "failure"}
		end
	end
  end

  def destroy
    Relationship.find(params[:id]).destroy
    redirect_to :back
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
end