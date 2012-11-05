class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end
  
  def help
  end

  def about
  end

  def contact
  end
  
  def friend
    if signed_in?
      @requests = current_user.received_friend_requests
      @sent_friend_requests = current_user.sent_friend_requests      
    end
  end
  
  def search
    if signed_in?
      @search_results = User.text_search params[:query]
    end
  end
  
  def crop
    if signed_in?
      current_user.update_attribute(:avatar, params[:file])
      sign_in(current_user, user_timezone)
      
      respond_to do |format|
        format.js
      end
    end
  end
  
  def crop_finish
    if signed_in?
      current_user.crop_x = params[:x] 
      current_user.crop_y = params[:y]
      current_user.crop_w = params[:w]
      current_user.crop_h = params[:h]
      
      current_user.crop_profile
      sign_in(current_user, user_timezone)
      
      redirect_to root_url
    end
  end
  
end
