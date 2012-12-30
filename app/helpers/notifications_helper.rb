module NotificationsHelper
	def gather_notifications(current_user) 
	  	html_output = "<ul class='notifications'>"
	  	current_user.notifications.order('created_at DESC').each do |n|
	  		html_output += notification_html(n)
	  	end
	  	html_output += "</ul>"
  	end
  	
  	def update_html(notifications)
  		html_output = ""
  		
  		notifications.each do |notification|
  			html_output += notification_html(notification)
  		end
  		
  		return html_output
  	end
  	
  	def notification_html(notification)
  		if notification.read == false
  			return unread_message(notification.link, notification.id, notification.message)
  		else
  			return read_message(notification.link, notification.id, notification.message)
  		end
  	end
  	
  	def unread_message(link, id, message)
  		return "<a href='"+ link + "'>" + "<li id='" + id.to_s + "' class='unread notification_item'>" + message + "</li></a>" 
  	end
  	
  	def read_message(link, id, message)
  		"<a href='"+ link + "'>" + "<li id='" + id.to_s + "' class='notification_item'>" + message + "</li>" + "</a>"
  	end

  	def create_notification(user_id, message, link)
  		if current_user.id != user_id
  			Notification.create!(user_id:user_id, message:message, link:link)
  		end
  	end
	
	def event_post(micropost)
		micropost.participations.each do |participant|
			if participant != current_user
				participant_id = participant.user_id
				message = current_user.name + " replied to '" + Micropost.find(@post.micropost_id).content + "'"
				link = detail_micropost_path(micropost.id)
				
				create_notification(participant_id, message, link)
			end
		end
	end
end
