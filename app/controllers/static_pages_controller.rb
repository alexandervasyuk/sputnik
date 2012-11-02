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
      ajax_upload = params[:file].is_a?(String)
      filename = ajax_upload  ? params[:file] : params[:file].original_filename
      extension = filename.split('.').last
  
      # Creating a temp file
      tmp_file = "#{Rails.root}/app/assets/images/temp/#{current_user.id}.#{extension}"
  
      # Save to temp file
      File.open(tmp_file, 'wb') do |f|
        if ajax_upload
          f.write  request.body.read
        else
          f.write params[:file].read
        end
      end
      
      session[:temp_profile] = "temp/#{current_user.id}.#{extension}"
      
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
      
      if current_user.add_profile(File.open("#{Rails.root}/app/assets/images/#{session[:temp_profile]}"))
        sign_in(current_user)
        redirect_to root_url
      end
    end
  end
  
end
