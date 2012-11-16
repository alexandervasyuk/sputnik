class PostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user,   only: :destroy

  def create
    @post = Post.create(params[:post])
    if @post.save
      MicropostMailer.delay.replied(@post)
      
      redirect_to :back
    else
      flash[:error] = 'Post can not be empty'
      @post_items = []
      redirect_to detail_micropost_path(@post.micropost_id)
    end
  end

  def destroy
    @post.destroy
    redirect_to :back
  end

  private

    def correct_user
      @post = current_user.posts.find_by_id(params[:id])
      redirect_to root_url if @post.nil?
    end
end