class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])
    timezone = params[:session][:timezone]
    if user && user.authenticate(params[:session][:password])
      sign_in(user, timezone)
      redirect_back_or root_url
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end