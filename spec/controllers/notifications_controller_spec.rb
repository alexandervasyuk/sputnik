require 'spec_helper'

describe NotificationsController do
	let(:user) { FactoryGirl.create(:user) }
	
	describe "mobile app user" do
		describe "who wants to see notifications" do
			describe "and is logged in" do
				before { sign_in(user) }
				
				it "should receive 10 notifications when there are not more than 10 new unread notifications" do
					unread_notifications = generate_unread_notifications(user, 5)
					read_notifications = generate_read_notifications(user, 10)
					
					get "index", format: "mobile"
					
					user.notifications.count.should == 15
					
					response.body.should == {status: "success", failure_reason: "", notifications: unread_notifications.reverse.concat(read_notifications.reverse.first(5)) }.to_json
				end
				
				it "should receive all unread notifications even if it exceeds 10" do
					unread_notifications = generate_unread_notifications(user, 11)
					
					get "index", format: "mobile"
					
					response.body.should == {status: "success", failure_reason: "", notifications: unread_notifications.reverse}.to_json
				end
			end
			
			describe "and is not logged in" do
				it "should not receive any notifications and give a failure indicator" do
					get "index", format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
				end
			end
		end
		
		describe "who wants older notifications" do
			let(:notifications) { generate_read_notifications(user, 11) }
		
			describe "and is not logged in" do
				it "should not receive any older notifications and should give a failure indicator" do
					get "index", oldest_id: notifications.last.id, format: "mobile"
					
					user.notifications.count.should == 11
					
					response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
				end
			end
			
			describe "and is logged in" do
				before { sign_in(user) }
			
				describe "and has an oldest notification" do
					it "should receive 10 older notifications if there are >= 10 older notifications" do
						get "index", oldest_id: notifications.last.id, format: "mobile"
						
						response.body.should == {status: "success", failure_reason: "", notifications: notifications[0..9].reverse}.to_json
					end
					
					it "should receive all remaining older notifications if there are < 10 of them" do
						get "index", oldest_id: notifications[9].id, format: "mobile"
						
						response.body.should == {status: "success", failure_reason: "", notifications: notifications[0..8].reverse}.to_json
					end
				end
			
				describe "and does not have an oldest notification" do
					it "should not receive any older notifications" do
						get "index", oldest_id: notifications[0].id, format: "mobile"
						
						response.body.should == {status: "success", failure_reason: "", notifications: []}.to_json
					end
				end
			end
		end
		
		describe "who wants newer notifications" do		
			describe "and is not logged in" do
				it "should not receive any newer notifications and should receive a failure indicator" do
					get "index", newest_id: nil, format: "mobile"
					
					response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
				end
			end
			
			describe "and is logged in" do
				before { sign_in(user) }
			
				describe "and has a newest notification" do
					it "should receive all newer notifications (read and unread)" do
						read_notifications = generate_read_notifications(user, 9)
						unread_notifications = generate_unread_notifications(user, 10)
					
						get "index", newest_id: read_notifications[4].id, format: "mobile"
						
						user.notifications.count.should == 19
						
						response.body.should == {status: "success", failure_reason: "", notifications: unread_notifications.reverse.concat(read_notifications[5..8].reverse)}.to_json
					end
				end
				
				describe "and does not have a newest notification" do
					it "should not receive any newer notifications" do
						read_notifications = generate_read_notifications(user, 9)
						unread_notifications = generate_unread_notifications(user, 10)
						
						get "index", newest_id: unread_notifications.last.id, format: "mobile"
						
						response.body.should == {status: "success", failure_reason: "", notifications: []}.to_json
					end
				end
			end
		end
		
		describe "who wants to mark some notifications read" do
			describe "and is not logged in" do
				describe "and provides notifications to be marked read" do
					let(:notifications) { generate_unread_notifications(user, 10) }
				
					it "should not mark those notifications read and should receive a failure indicator" do
						notification_ids = []
						
						notifications.each do |notification|
							notification_ids << notification.id
						end
					
						post "update_read", notification_ids: notification_ids, format: "mobile"
						
						response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
						
						notifications.each do |notification|
							notification.unread?.should be_true
						end
					end
				end
				
				describe "and does not provide notifications to be marked read" do
					let(:notifications) { generate_unread_notifications(user, 10) }
					
					it "should not change notifications in any way and should receive a failure indicator" do
						post "update_read", notification_ids: nil, format: "mobile"
						
						response.body.should == {status: "failure", failure_reason: "LOGIN"}.to_json
						
						notifications.each do |notification|
							notification.reload.unread?.should be_true
						end
					end
				end
			end
			
			describe "and is logged in" do
				before { sign_in(user) }
			
				describe "and have notifications to mark" do
					describe "and own those notifications" do
						let(:notifications) { generate_unread_notifications(user, 10) }
					
						it "should mark those notifications as read and receive a success indicator" do
							notification_ids = []
						
							notifications.each do |notification|
								notification_ids << notification.id
							end
							
							post "update_read", notification_ids: notification_ids, format: "mobile"
							
							notifications.each do |notification|
								notification.reload.unread?.should be_false
							end
							
							response.body.should == {status: "success", failure_reason: ""}.to_json
						end
					end
					
					describe "and do not own those notifications" do
						let(:other_user) { FactoryGirl.create(:user) }
					
						it "should not mark those notifications as read" do
							notifications = generate_unread_notifications(other_user, 10)
							
							notification_ids = []
						
							notifications.each do |notification|
								notification_ids << notification.id
							end
							
							post "update_read", notification_ids: notification_ids, format: "mobile"
							
							notifications.each do |notification|
								notification.reload.unread?.should be_true
							end
							
							response.body.should == {status: "success", failure_reason: ""}.to_json
						end
					end
				end
				
				describe "and do not have notifications to mark" do
					it "should not change anything about notifications" do
					
					end
					
					it "should receive a success indicator" do
					
					end
				end
			end
		end
	end
end
