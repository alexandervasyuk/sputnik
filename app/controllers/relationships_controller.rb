class RelationshipsController < ApplicationController
  before_filter :signed_in_user

  respond_to :html, :js

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.friend_request!(@user)
    
    UserMailer.delay.friend_requested(current_user, @user)
    
    respond_with @user
  end
  
  def update
    if params[:type] == 'ACCEPT'
      @user = User.find(params[:relationship][:follower_id])
      current_user.accept_friend!(@user)
		
      redirect_to :back
    elsif params[:type] == 'IGNORE'
      relationship = Relationship.find(params[:id])
      relationship.friend_status = "IGNORED"
      relationship.save
      
      redirect_to :back
    elsif params[:type] == 'UNFOLLOW'
      @user = User.find(params[:side])
      current_user.unfollow!(@user)
        
      @type_and_user = [params[:type], @user]
      
      respond_with @type_and_user
    elsif params[:type] == 'FOLLOW'  
      @user = User.find(params[:side])
      current_user.follow!(@user)
      
      @type_and_user = [params[:type], @user]
      
      respond_with @type_and_user
    end
  end

  def destroy
    Relationship.find(params[:id]).destroy
    redirect_to :back
  end
end