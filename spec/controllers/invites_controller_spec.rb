require 'spec_helper'

describe InvitesController do
	describe "following an email invite link" do 
		describe "invite is a valid one" do
			let(:event) { FactoryGirl.create(:micropost) }
			
			describe "user is temp" do
				let(:invited) { FactoryGirl.create(:temp_user) }
			
				it "should redirect to the signup page" do
					post "invite_redirect", {uid: invited.id, eid: event.id}
					response.should render_template('new')
				end
			end
			
			describe "user is signed up" do
				let(:invited) { FactoryGirl.create(:user) }
			
				it "should redirect to the event page and the user is signed up" do
					post "invite_redirect", {uid: invited.id, eid: event.id}
					response.should redirect_to(detail_micropost_path(event.id))	
				end
			end
		end
		
		describe "invite is not a valid one" do
			let(:event) { FactoryGirl.build(:unsaved_micropost) }
			let(:invited) { FactoryGirl.build(:unsaved_user) }
			
			it "should redirect back to the main page with an error saying that the invite was invalid" do
				event.id.should == 1
				invited.id.should == 1
				
				Micropost.stub(:find).and_return(nil)
				User.stub(:find).and_return(nil)
				
				post "invite_redirect", {uid: invited.id, eid: event.id}
				flash[:error].should_not be_nil
				response.should redirect_to(root_url)
			end
		end
	end
end