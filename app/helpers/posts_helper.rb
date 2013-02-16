module PostsHelper
	def set_latest_post(micropost, post)
		if post.present?
			session["micropost-#{micropost.id}-latest-post"] = post.id
		end
	end
	
	def get_later_posts(micropost)
		later_posts = micropost.posts.where("id > ?", session["micropost-#{micropost.id}-latest-post"]).order("id DESC")
		
		if !later_posts.empty?
			set_latest_post(micropost, later_posts.first)
		end
		
		return later_posts
	end
	
	def get_later_mobile_posts(micropost)
		later_posts = get_later_posts(micropost)
		
		later_posts.collect { |later_post| later_post.to_mobile }
	end
	
	def add_deleted_post(post)
		(session[:posts_to_delete] ||= []) << post.id
	end
	
	def retrieve_deleted_posts
		temp = (session[:posts_to_delete] ||= []).dup
		session[:posts_to_delete].clear
		
		return temp
	end
end