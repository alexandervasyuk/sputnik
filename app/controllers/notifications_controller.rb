class NotificationsController < ApplicationController
	def update_read
		params[:ids].each do |id|
			Notification.find(id).update_attribute(:read, true)
		end
		render text: params[:ids]
	end
	
	def ajax_update
		
	end
end
