class NotificationsController < ApplicationController
	def update_read
		params[:ids].each do |id|
			Notification.find(id).update_attribute(:read, true)
		end
		render text: params[:ids]
	end
	
	def ajax_update
		new_notifications = current_user.later_unread_notifications(params[:latest])
		
		if new_notifications.blank?
			render text: "cancel"
		else
			render json: [update_html(new_notifications), new_notifications[0].id]
		end
	end
end
