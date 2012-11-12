class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if params[:micropost][:time][0..1] == "at"
      @micropost.time = Time.parse(params[:micropost][:time])
    else
      Time.use_zone(user_timezone) do
        Chronic.time_class = Time.zone
        @micropost.time = Chronic.parse(params[:micropost][:time])
      end
    end
    if @micropost.save
      current_user.participate!(@micropost)
      redirect_to root_url
    else
      @feed_items = current_user.future_feed
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to :back
  end

  def edit
    @micropost = Micropost.find(params[:id])
  end

  def update
    @micropost = Micropost.find(params[:id])

    if params[:micropost][:time].empty?
      render 'edit'
      return
    end

    if params[:micropost][:time][0..1] == "at"
      @micropost.time = Time.parse(params[:micropost][:time])
    else
      @micropost.time = Chronic.parse(params[:micropost][:time])
    end

    if  !Chronic.parse(params[:micropost][:time])
      params[:micropost][:time] = Time.parse(params[:micropost][:time])
    else
      params[:micropost][:time] = Chronic.parse(params[:micropost][:time])
    end

    if @micropost.update_attributes(params[:micropost])
      redirect_to(action:'detail', id:@micropost.id)
    else
      render 'edit'
    end
  end

  def detail
    @micropost = Micropost.find(params[:id])
    
    if current_user.friends?(@micropost.user)
      @post = current_user.posts.build(micropost_id:params[:id])
      @participants = []
      @micropost.participations.each do |participation|
        @participants << User.find(participation.user_id)
      end
      @post_items = @micropost.posts.reverse!
    else  
      redirect_to root_url
    end
  end
  
  #Action responsible for rendering an updated user feed
  def refresh
    @feed_items = current_user.future_feed
    
    if params[:num].to_i == @feed_items.count
      render text: "cancel"
    else  
      render partial:'shared/feed'
    end
    
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end
end