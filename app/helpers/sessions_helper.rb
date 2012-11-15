module SessionsHelper

  def sign_in(user, timezone)
    cookies.permanent[:remember_token] = user.remember_token
    cookies.permanent[:timezone] = timezone
    self.current_user = user
    self.user_timezone = timezone
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
    cookies.delete(:remember_token)
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
