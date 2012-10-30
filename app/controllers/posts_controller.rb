class PostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

  def create
    @post = Post.create(params[:post])
    if @post.save
      redirect_to :back
    else
      flash[:error] = 'Post can not be empty'
      @post_items = []
      redirect_to detail_micropost_path(@post.micropost_id)
    end
  end

  def destroy
    @post.destroy
    redirect_to root_url
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_url if @micropost.nil?
    end
end