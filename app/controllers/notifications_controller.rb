class NotificationsController < ApplicationController
	
	before_filter :signed_in_user
	
	protect_from_forgery
	
	def index
		respond_to do |format|
			if params[:oldest_id] && (Integer(params[:oldest_id]) rescue false)
				# Requesting older notifications
				notifications = current_user.older_notifications(params[:oldest_id])
				
				format.mobile do
					render json: { status: "success", failure_reason: "", notifications: notifications }
				end
			elsif params[:newest_id] && (Integer(params[:newest_id]) rescue false)
				# Requesting newer notifications
				notifications = current_user.newer_notifications(params[:newest_id])
				
				format.mobile do
					render json: { status: "success", failure_reason: "", notifications: notifications }
				end
			elsif params[:oldest_id].nil? && params[:newest_id].nil?
				# Requesting notifications
				notifications = current_user.retrieve_notifications
				
				format.mobile do
					render json: { status: "success", failure_reason: "", notifications: notifications } 
				end
			else	
				format.mobile do
					render json: { status: "failure", failure_reason: "INVALID TYPES", notifications: [] }
				end
			end
		end
	end
	
	def update_read
		params[:notification_ids].each do |id|
			notification = current_user.notifications.find_by_id(id)
			
			if notification
				notification.update_attribute(:read, true)
			end
		end
	
		respond_to do |format|
			format.mobile { render json: {status: "success", failure_reason: ""} }
			format.js
		end
	end
	
	def ajax_update
		new_notifications = current_user.newer_notifications(params[:latest])
		
		if new_notifications.blank?
			render text: "cancel"
		else
			render json: [update_html(new_notifications), new_notifications[0].id]
		end
	end
end
