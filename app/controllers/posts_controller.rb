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
    redirect_to :back
  end
  
  #Code to handle ajax pulling requests
  def refresh
  	@micropost = Micropost.find(params[:id])
  	
  	if @micropost
  		@post_items = @micropost.posts
  		
  		if params[:num].to_i == @post_items.count
  			render text: "cancel"
  		else
  			render partial: 'microposts/post_item', collection: @post_items
  		end
  	end
  end

  private

    def correct_user
      @post = current_user.posts.find_by_id(params[:id])
      redirect_to root_url if @post.nil?
    end
end