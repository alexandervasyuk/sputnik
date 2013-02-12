class NotificationsController < ApplicationController
	
	before_filter :signed_in
	
	def index
		respond_to do |format|
			if params[:oldest_id]
				notifications = current_user.older_notifications(params[:oldest_id])
				
				format.mobile do
					render json: { status: "success", notifications: notifications }
				end
			else
				notifications = current_user.retrieve_notifications
				
				format.mobile do
					render json: { status: "success", notifications: notifications } 
				end
			end
		end
	end
	
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
	
	private
	
	def signed_in
		if !signed_in?
			respond_to do |format|
				format.mobile { render json: {status: "failure", notifications: [] } }
			end
		end
	end
end
