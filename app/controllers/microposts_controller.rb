class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(params[:micropost])

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

  def detail
    @micropost = Micropost.find(params[:id])
    @post = current_user.posts.build(micropost_id:params[:id])
    @participants = []
    @micropost.participations.each do |participation|
      @participants << User.find(participation.user_id)
    end
    @post_items = @micropost.posts.paginate(page: params[:page])
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end
end