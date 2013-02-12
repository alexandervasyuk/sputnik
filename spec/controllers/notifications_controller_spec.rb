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
					
					response.body.should == {status: "success", notifications: unread_notifications.reverse.concat(read_notifications.reverse.first(5)) }.to_json
				end
				
				it "should receive all unread notifications even if it exceeds 10" do
					unread_notifications = generate_unread_notifications(user, 11)
					
					get "index", format: "mobile"
					
					response.body.should == {status: "success", notifications: unread_notifications.reverse}.to_json
				end
			end
			
			describe "and is not logged in" do
				it "should not receive any notifications and give a failure indicator" do
					get "index", format: "mobile"
					
					response.body.should == {status: "failure", notifications: []}.to_json
				end
			end
		end
		
		describe "who wants older notifications" do
			describe "and is not logged in" do
				it "should not receive any older notifications" do
				
				end
				
				it "should receive a failure indication, which means that I must log in first" do
				
				end
			end
			
			describe "and is logged in" do
				describe "and has an oldest notification" do
					it "should receive 10 older notifications if there are >= 10 older notifications" do
					
					end
					
					it "should receive all remaining older notifications if there are < 10 of them" do
					
					end
				end
			
				describe "and does not have an oldest notification" do
					it "should not receive any older notifications" do
						
					end
				end
			end
		end
		
		describe "who wants newer notifications" do
			describe "and is not logged in" do
				it "should not receive any newer notifications" do
				
				end
				
				it "should receive a failure indicator, which means that I must log in" do
				
				end
			end
			
			describe "and is logged in" do
				describe "and has a newest notification" do
				
				end
				
				describe "and does not have a newest notification" do
				
				end
			end
		end
		
		describe "who wants to mark some notifications read" do
			describe "and is not logged in" do
				describe "and provides notifications to be marked read" do
					it "should not mark those notifications read" do
					
					end
					
					it "should receive a failure indicator, along with the failure reason being not logged in" do
					
					end
				end
				
				describe "and does not provide notifications to be marked read" do
					it "should not change notifications in any way" do
					
					end
					
					it "should receive a failure indicator, along with the failure reason being not logged in" do
					
					end
				end
			end
			
			describe "and is logged in" do
				describe "and have notifications to mark" do
					describe "and own those notifications" do
						it "should mark those notifications as read" do
						
						end
						
						it "should receive a success indicator" do
						
						end
					end
					
					describe "and do not own those notifications" do
						it "should not mark those notifications as read" do
						
						end
						
						it "should receive a failure indicator, along with the failure reason being not owning those notifications" do
						
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
