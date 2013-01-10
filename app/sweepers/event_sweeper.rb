class EventSweeper < ActionController::Caching::Sweeper
	observe Micropost
	
	def after_safe(micropost)
		clear_event_cache(micropost)
	end
	
	def after_destroy(micropost)
		clear_event_cache(micropost)
	end
	
	def clear_event_cache(micropost)
		expire_page controller: :microposts, action: :detail, id: micropost.id
	end
end