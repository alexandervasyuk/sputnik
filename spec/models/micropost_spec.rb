require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Lorem ipsum") }

  subject { @micropost }

  # Respond to Attributes
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:location) }
  it { should respond_to(:time) }
  it { should respond_to(:end_time) }
  it { should respond_to(:latitude) }
  it { should respond_to(:longitude) }
  it { should respond_to(:invitees) }
  
  its(:user) { should == user }

  it { should be_valid }

  # Validation Tests
  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        Micropost.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end
  
  # Time Validation Tests
  describe "with start time in the past" do
	before { @micropost.time = Time.now - 5.minutes }
	
	it { should_not be_valid }
  end
  
  describe "with only start time" do
	before { @micropost.time = Time.now }
	
	it { should be_valid }
  end
  
  describe "with only end time" do
	before { @micropost.end_time = Time.now }
	
	it { should_not be_valid }
  end
  
  describe "with start time before end time" do
	before do
		@micropost.time = Time.now
		@micropost.end_time = @micropost.time + 5.minutes
	end
	
	it { should be_valid }
  end
  
  describe "with start time after end time" do
	before do
		@micropost.time = Time.now
		@micropost.end_time = @micropost.time - 5.minutes
	end
	
	it { should_not be_valid }
  end
  
  # Association Tests
  
  # ActiveRecord Callback Tests (create, delete, etc.)
  
  # Destroy Tests
  describe "destroying a micropost" do
	it "should remove all participations attached to it" do
		micropost_destroying = FactoryGirl.create(:micropost)
		num_participants = 5
		
		generate_participants(micropost_destroying, num_participants)
	
		expect do
			micropost_destroying.destroy
		end.to change{ Participation.count }.by(-1 * num_participants)
	end
	
	it "should remove all posts attached to it" do
		micropost_destroying = FactoryGirl.create(:micropost)
		num_posts = 6
		
		generate_posts_for(micropost_destroying, num_posts)
		
		expect do
			micropost_destroying.destroy
		end.to change{Post.count}.by(-1 * num_posts)
	end
	
	it "should remove all polls attached to it" do
		micropost_destroying = FactoryGirl.create(:micropost)
		num_polls = 4
		
		generate_polls_for(micropost_destroying, num_polls)
		
		expect do
			micropost_destroying.destroy
		end.to change{ Poll.count }.by(-1 * num_polls)
	end
	
	it "should remove all characteristics attached to it" do
		micropost_destroying = FactoryGirl.create(:micropost)
		num_characteristics = 7
		
		generate_characteristics_for(micropost_destroying, num_characteristics)
		
		expect do
			micropost_destroying.destroy
		end.to change{ Characteristic.count }.by(-1 * num_characteristics)
	end
  end
  
  
  
end