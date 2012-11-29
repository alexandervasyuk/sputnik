module NotificationsHelper
	def gather_notifications(current_user) 
	  	html_output = "<ul class='notifications'>"
	  	current_user.notifications.order('created_at DESC').each do |n|
	  		if n.read == false
	  			html_output += "<a href='"+ n.link + "'>" + "<li id='" + n.id.to_s + "' class='unread notification_item'>" + n.message + "</li>" + "</a>"
	  		else
	  			html_output += "<a href='"+ n.link + "'>" + "<li id='" + n.id.to_s + "' class='notification_item'>" + n.message + "</li>" + "</a>"
	  		end
	  			
	  	end
	  	html_output += "</ul>"
  	end

  	def create_notification(user_id, message, link)
  		if current_user.id != user_id
  			Notification.create!(user_id:user_id, message:message, link:link)
  		end
  	end
end
