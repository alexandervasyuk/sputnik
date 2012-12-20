require 'spec_helper'

describe MicropostsController do
	let(:user) { FactoryGirl.create(:user) }		
	before { sign_in user }
	
	describe "creating a new micropost" do	
		describe "no errors in form input" do			
			it "should successfully save the record and render the home page" do
				["now"].each do |time|
					micropost = {micropost: {content: "Lorem ipsum", location: "Lorem ipsum", time: time}}
					
					post "create", micropost
					response.should render_template('static_pages/home')
				end
			end
		end
		
		describe "errors in form input" do
			it "should not create records on incorrectly formatted times" do
				["", "hi"].each do |time|
					micropost = {micropost: {content: "Lorem Ipsum", location: "Lorem Ipsum", time: time}}
				
					microposts_before = Micropost.all.count
					
					post "create", micropost
					
					microposts_after = Micropost.all.count
					
					microposts_before.should == microposts_after
				end
			end
		end
	end
	
	describe "destroying a micropost" do
		it "should destroy a micropost if the user owns the micropost" do
			micropost = FactoryGirl.create(:micropost, user: user)
			
			delete = {id: micropost.id}
			
			microposts_before = Micropost.all.count
			post "destroy", delete
			microposts_after = Micropost.all.count
			
			microposts_after.should == microposts_before - 1	
		end
		
		it "should not destroy a micropost if the user does not own the micropost" do
			micropost = FactoryGirl.create(:micropost, user: user)
			
			other_user = FactoryGirl.create(:user)
			other_micropost = FactoryGirl.create(:micropost, user: other_user)
			
			microposts_before = Micropost.all.count
			post "destroy", {id: other_micropost.id}
			microposts_after = Micropost.all.count
				
			microposts_after.should == microposts_before
			flash[:error].should_not be_nil
			response.should redirect_to(root_url)
		end
	end
	
	describe "updating a micropost" do
		describe "the user owns the micropost" do
		    let(:micropost) { FactoryGirl.create(:micropost, user: user) }
		    let(:num_participants) { 3 }
		
			it "should update the micropost" do
				edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
				post "update", edit
				
				updated_micropost = Micropost.find(micropost.id)
				updated_micropost.content.should == "new content"
				updated_micropost.location.should == "new location"
				
				response.should redirect_to(detail_micropost_path(micropost.id))
			end
			
			it "should not update the micropost if the input fields are incorrect" do
				
			end
			
			describe "there is one participant" do
				before { generate_participants micropost, 1 }
				
				it "should send an email to one participant on update" do
					ActionMailer::Base.deliveries = []
					
					edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
					post "update", edit
					
					mail = ActionMailer::Base.deliveries.last
					
					participants = micropost.participations
					
					mail['from'].to_s.should == "John via Happpening <notification@happpening.com>"
					mail['to'].to_s.should == participants[0].user.email
					
					updated_micropost = Micropost.find(micropost.id)
					updated_micropost.content.should == "new content"
					updated_micropost.location.should == "new location"
		    	end
	    	end
	    	
	    	describe "there are multiple participants" do
	    		before { generate_participants micropost, num_participants }
	    		
		    	it "should send emails to all participants on update" do
		    		ActionMailer::Base.deliveries = []
		    		
		    		micropost.participations.count.should == num_participants
		    		
		    		edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
					post "update", edit
					
					participants = micropost.participations
					
					#ActionMailer::Base.deliveries.last['from'].to_s.should be_nil
					emails = [participants[0].user.email, participants[1].user.email, participants[2].user.email]
					
					ActionMailer::Base.deliveries.last(3).each do |mail|
						emails.should include(mail['to'].to_s)
					end
					
					ActionMailer::Base.deliveries.count.should == num_participants
		    	end
		    	
		    	it "should send internal notifications to all participants on update" do
		    		ActionMailer::Base.deliveries = []
		    	end
	    	end
		end
		
		it "should not update the micropost if the user does not own the micropost" do
			micropost = FactoryGirl.create(:micropost)
			
			edit = {id: micropost.id, micropost: {content: "new content", location: "new location", time: micropost.time}}
			post "update", edit
			
			updated_micropost = Micropost.find(micropost.id)
			updated_micropost.content.should_not == "new content"
			updated_micropost.location.should_not == "new location"
			
			flash[:error].should_not be_nil
			response.should redirect_to(root_url)
		end
	end

	describe "displaying information about a micropost" do
		let(:micropost) { FactoryGirl.create(:micropost, user: user) }
		let(:friend) { FactoryGirl.create(:user) }
		let(:not_friend) { FactoryGirl.create(:user) }
		let(:data) { {id: micropost.id} }
	
		describe "on the web app" do
			it "should correctly return the detail page when the users are friends" do
				make_friends(user, friend)
				sign_in(friend)
				
				post "detail", data
				
				response.should render_template("microposts/detail")
			end
			
			it "should redirect to the root url if the users are not friends" do
				sign_in(not_friend)
				
				post "detail", data
				
				response.should redirect_to(root_url)
			end
		end
		
		describe "on the mobile app" do
			before { generate_posts_for(micropost, 3) }
		
			it "should correctly return the information as json when the users are friends" do
				make_friends(user, friend)
				sign_in(friend)
			
				replies_data = []
				
				micropost.posts.each do |post|
					replies_data << {replier_picture: post.user.avatar.url, reply_text: post.content, replier_name: post.user.name, posted_time: post.created_at }
				end
				
				post "mobile_detail", data
				
				response_json = {status: "success", replies_data: replies_data}.to_json
				
				response.body.should == response_json
			end
			
			it "should return an error code as json to the mobile app" do
				response_json = {status:"failure", replies_data:[]}.to_json
				
				sign_in(not_friend)
				
				post "mobile_detail", data
				
				response.body.should == response_json
			end
		end
	end
end