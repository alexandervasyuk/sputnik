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
  		feed = @user.feed
		
		session[:feed_latest] = feed.maximum("updated_at")
  		
  		mobile_feed = []
  		feed.each do |feed_item|
  			mobile_feed << feed_item.to_mobile
  		end
  		
  		json_response = {status: "success", feed_data: mobile_feed}
  		
  		render json: json_response
  	else
  		json_response = {status: "failure", feed_data:[]}
  		
  		render json: json_response
  	end
  end

  def destroy 
    sign_out
    redirect_to root_url
  end
  
  #BEFORE FILTER - performs the sign in check
  def log_in
  	@user = User.find_by_email(params[:session][:email].downcase)
    timezone = params[:session][:timezone] || params[:session][:timezone_on_signin]
    
    @sign_in_success = @user && !@user.temp && @user.authenticate(params[:session][:password])
    
    if @sign_in_success
      sign_in(@user, timezone)
	  set_location(request)
	end
  end
end