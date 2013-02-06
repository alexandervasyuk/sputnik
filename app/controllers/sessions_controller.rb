class SessionsController < ApplicationController
  before_filter :log_in, only: [:create, :create_mobile]
	
  protect_from_forgery except: :create_mobile	
	
  def new
  end

  def create
  	if @sign_in_success
  		redirect_back_or root_url
  	else
  		cookies.delete(:timezone)
     	flash.now[:error] = 'Invalid email/password combination'
      	render 'new'
  	end
  end
  
  def create_mobile
  	if @sign_in_success
  		mobile_feed = []
		mobile_pool = []
		
		feed = @user.feed
		
  		feed.each do |feed_item|
  			mobile_feed << feed_item.to_mobile
  		end
		
		pool = @user.pool
		
		pool.each do |pool_item|
			mobile_pool << pool_item.to_mobile
		end
  		
  		json_response = {status: "success", name: @user.name, id: @user.id, feed_data: mobile_feed, pool_data: mobile_pool}
  		
  		render json: json_response
  	else
  		json_response = {status: "failure", name: nil, id: nil, feed_data:[], pool_data: []}
  		
  		render json: json_response
  	end
  end

  def destroy 
    sign_out
    redirect_to root_url
  end
  
  def destroy_mobile
	sign_out
	
	json_response = {status: "success"}
	
	render json: json_response
  end
  
  #BEFORE FILTER - performs the sign in check
  def log_in
  	@user = User.find_by_email(params[:session][:email].downcase)
    timezone = params[:session][:timezone] || params[:session][:timezone_on_signin]
    
    @sign_in_success = @user && !@user.temp && @user.authenticate(params[:session][:password])
    
    if @sign_in_success
      sign_in(@user, timezone)
	  set_location(request)
	  
	  session[:feed_latest] = @feed.maximum("updated_at")
	end
  end
end