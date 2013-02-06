module SessionsHelper
  def sign_in(user, timezone)
    cookies.permanent[:remember_token] = user.remember_token
    cookies.permanent[:timezone] = timezone
    self.current_user = user
    self.user_timezone = timezone
  end
  
  def set_location(request)
	geolocation_result = GeoIp.geolocation(request.remote_ip)
	
	if !Rails.env.development? && !Rails.env.test?
		cookies.permanent[:latitude] = (geolocation_result[:latitude].to_f * 1000).round / 1000.0
		cookies.permanent[:longitude] = (geolocation_result[:longitude].to_f * 1000).round / 1000.0
	else
		cookies.permanent[:latitude] = (39.07993 * 1000).round / 1000.0
		cookies.permanent[:longitude] = (-77.181175 * 1000).round / 1000.0
	end	
  end
  
  def current_location
	{latitude: cookies[:latitude], longitude: cookies[:longitude]}
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def sign_out
    clean_up
    
    current_user = nil
    cookies.delete(:return_to)
    cookies.delete(:remember_token)
    cookies.delete(:timezone)
	cookies.delete(:current_location)
  end
  
  def clean_up
    clear_temp_profile_pic
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end

  def user_timezone=(timezone)
    @user_timezone = timezone
  end

  def user_timezone
    @user_timezone ||= cookies[:timezone]
  end

end
