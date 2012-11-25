class UsersController < ApplicationController
  before_filter :signed_in_user, 
                only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy
  before_filter :not_temp, only: :show

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
  	@tempuser = User.find_by_email(params[:user][:email])
  	
  	temp_created = false
  	
    @user = User.new(params[:user])
    if !@tempuser.nil? && @tempuser.temp
    	@user = @tempuser
    	@user.update_attributes(params[:user])	
    	@user.temp = false
    	temp_created = true
    end

    if @user.save
      sign_in(@user, params[:timezone])      
      flash[:success] = "Welcome to Happpening!"
	
      UserMailer.delay.signed_up(@user)
	
      if temp_created
      	redirect_to "/friend"	
  	  else
  		redirect_to root_path
  	  end
    else
      render 'users/new'
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

	def correct_user
	  @user = User.find(params[:id])
	  redirect_to(root_url) unless current_user?(@user)
	end
	
	def not_temp
		user = User.find(params[:id])
		redirect_to root_url if user.temp
	end
	
	def admin_user
	  redirect_to(root_url) unless current_user.admin?
	end
end