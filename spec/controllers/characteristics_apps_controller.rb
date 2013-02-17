require 'spec_helper'

describe CharacteristicsAppsController do
	describe "mobile app user" do
		describe "who is logged in" do
			describe "who is friends with the creator of the micropost" do
				describe "who is participating in the micropost" do
					describe "when there is not a characteristics app" do
						describe "who wants to create a new characteristics app" do
							
						end
						
						describe "who wants to destroy a characteristics app" do
						
						end
					end
					
					describe "when there is a characteristic app" do
						describe "who wants to create a new characteristics app" do
						
						end
						
						describe "who wants to destroy a characteristics app" do
						
						end
					end
				end
				
				describe "who is not participating in the micropost" do
				
				end
			end
			
			describe "who is not friends with the creator of the micropost" do
			
			end
		end
		
		describe "who is not logged in" do
			it "should not create a new characteristics app and should respond with a login failure" do
				
			end
			
			it "should not destroy a characteristics app and should respond with a login failure" do
			
			end
		end
	end
end