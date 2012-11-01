class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    @micropost.time = Chronic.parse(params[:micropost][:time])
    if @micropost.save
      current_user.participate!(@micropost)
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end

  def edit
    @micropost = Micropost.find(params[:id])
  end

  def update
    @micropost = Micropost.find(params[:id])
    params[:micropost][:time] = Chronic.parse(params[:micropost][:time])
    if @micropost.update_attributes(params[:micropost])
      flash[:success] = "Micropost updated"
      redirect_to(action:'detail', id:@micropost.id)
    else
      render "edit"
    end
  end

  def detail
    @micropost = Micropost.find(params[:id])
    @post = current_user.posts.build(micropost_id:params[:id])
    @participants = []
    @micropost.participations.each do |participation|
      @participants << User.find(participation.user_id)
    end
    @post_items = @micropost.posts.reverse!
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end
end