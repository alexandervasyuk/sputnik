require 'spec_helper'

describe SessionsController do
	let(:user) { FactoryGirl.create(:user) }
	let(:timezone) { "America/Los_Angeles" }
	
	describe "signing in" do
		describe "password is correct" do
			let(:password) { "foobar" }
			let(:session) { {session: {email: user.email, timezone: timezone, password: password}} }
			
			describe "with a temp account" do
				#MISSING TEST
			end
			
			describe "from a desktop" do
				it "should sign in correctly" do
					post "create", session
					
					response.should redirect_to(root_url)
				end
			end
			
			describe "from a mobile app" do
				describe "with no feed and no pool" do
					it "should sign in correctly" do
						post "create_mobile", session
						expected = {status: "success", name: user.name, id: user.id, feed_data: [], pool_data: []}.to_json
						
						response.body.should == expected
					end
				end
				
				describe "with a feed" do
					before { generate_feed_items(user, 3) }
					it "should return all of the feed in the feed_data" do
						post "create_mobile", session
						
						feed_data = []
						user.feed.each do |feed_item|
							feed_data << feed_item.to_mobile
						end
						
						expected = {status: "success", name: user.name, id: user.id, feed_data: feed_data, pool_data: []}.to_json
						
						response.body.should == expected
					end
				end
			end
		end
		
		describe "password is incorrect" do
			let(:password) { "incorrect" }
			let(:session) { {session: {email: user.email, timezone: timezone, password: password}} }
			
			describe "from a desktop" do
				it "should not sign in" do
					post "create", session
					
					response.should render_template('new')
				end
			end
			
			describe "from a mobile app" do
				it "should not sign in" do
					post "create_mobile", session
					
					expected = {status: "failure", name: nil, id: nil, feed_data: [], pool_data: []}.to_json
					
					response.body.should == expected
				end
			end			
		end
	end
end