class UsersController < ApplicationController
  before_filter :signed_in_user, 
                only: [:index, :show, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy
  before_filter :not_temp, only: [:show, :show_mobile]
  
  before_filter :temp_create, only: [:create, :create_mobile]
  after_filter :create_mail, only: [:create, :create_mobile]
  
  protect_from_forgery except: [:create_mobile, :show_mobile]

  def show
    @microposts = @user.microposts.paginate(page: params[:page])
  end
  
  def show_mobile
	if @user == current_user
		events = current_user.feed
	
		json_response = {status: "success", picture: @user.avatar.url, is_user: true, is_friends: false, is_pending: false, is_waiting: false, events: events}
		
	elsif @user.friends?(current_user)	
		events = @user.feed
		
		json_response = {status: "success", picture: @user.avatar.url, is_user: false, is_friends: true, is_pending: false, is_waiting: false, events: events}
		
	elsif current_user.pending?(@user)	
		json_response = {status: "success", picture: @user.avatar.url, is_user: false, is_friends: false, is_pending: true, is_waiting: false, events: []}
		
	elsif @user.pending?(current_user)	
		json_response = {status: "success", picture: @user.avatar.url, is_user: false, is_friends: false, is_pending: false, is_waiting: true, events: []}
		
	else	
		json_response = {status: "failure", picture: @user.avatar.url, is_user: false, is_friends: false, is_pending: false, is_waiting: false, events: []}
		
	end
	
	render json: json_response
  end

  def new
    @user = User.new
  end

  def create
    if @created
		sign_in(@user, params[:timezone])   
		flash[:success] = "Welcome to Happpening!"
		
		if @temp_created
			redirect_to "/friend"
		else
			redirect_to root_path
		end
    else
		render 'users/new'
    end
  end
  
  def create_mobile
	if @created
		sign_in(@user, params[:timezone])
		
		json_response = {status: "success", failure_reason: ""}
		
		render json: json_response
	else
		json_response = {status: "failure", failure_reason: ""}
	
		render json: json_response
	end
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

  #BEFORE FILTER - filters to make sure the owner of account can edit the details
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  #BEFORE FILTER - filters to make sure that the user that the user is trying to access is not a temporary user
  def not_temp
	@user = User.find(params[:id])
	redirect_to root_url if @user.temp
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
  
  #BEFORE FILTER - filters to make sure that the special temp user case is handled gracefully
  def temp_create
	tempuser = User.find_by_email(params[:user][:email])
  	
	@temp_created = false
	
	# Checks if the user is a temporary/invited user
    if tempuser && tempuser.temp
    	@user = tempuser
		@user.temp = false
		
    	if @user.update_attributes(params[:user])
			@temp_created = true
		end
	else	
		@user = User.new(params[:user])
    end
	
	if (is_in_beta && @temp_created) || !is_in_beta
		@created = @temp_created || @user.save
	end
  end
  
  #AFTER FILTER - filters the creation methods to send out the emails on success
  def create_mail
	if @created
		UserMailer.delay.signed_up(@user)
	end
  end
end