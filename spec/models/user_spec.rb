require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
	@friend = FactoryGirl.create(:user)
	@random_user = FactoryGirl.create(:user)
	@friend_requester = FactoryGirl.create(:user)
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:microposts) }
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }

  it { should be_valid }
  it { should_not be_admin }

  # Validation Testing
  
  describe "accessible attributes" do
    it "should not allow access to admin" do
      expect do
        User.new(admin: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it { should be_admin }
  end
  
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when email is not present" do
    before { @user.email = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  # Associations Tests
  
  # Instance Methods Tests
  
  describe "password reset" do
	before do
		@user.save
		@user.send_password_reset
	end
	
	its(:password_reset_token) { should_not be_blank }
  end
  
  # Instance Method Testing
  
  describe "feed" do
	before do
		@user.save
		make_friends(@user, @friend)
	end
	
	let(:feed_item) { generate_feed_item(@user) }
	
	it "should populate the feed of the creator successfully" do
		@user.feed.should include(feed_item)
	end
	
	it "should populate the pool of the creator successfully" do
		@user.pool.should_not include(feed_item)
	end
	
	it "should populate the feed of the creator's friends successfully" do
		@friend.feed.should include(feed_item)
	end
	
	it "should populate the pool of the creator's friends successfully" do
		@friend.pool.should_not include(feed_item)
	end
  end
  
  describe "pool" do
	before do
		@user.save
		make_friends(@user, @friend)
	end
	
	let(:pool_item) { generate_pool_item(@user) }
	
	it "should populate the pool of the creator successfully" do
		Rails.logger.debug("\n\nEnter pool test #1\n\n")
	
		@user.pool.should include(pool_item) 
	end
	
	it "should populate the feed of the creator successfully" do
		@user.feed.should_not include(pool_item)
	end
	
	it "should populate the pool of the creator's friends successfully" do
		@friend.pool.should include(pool_item)
	end
	
	it "should populate the feed of the creator's friends successfully" do
		@friend.feed.should_not include(pool_item)
	end
  end
  
  # Testing feed update responds correctly to different update times
  describe "feed update" do
	before { @user.save }
  
	it "should respond will nil when the input is nil" do
		@user.feed_after(nil).should be_nil
	end	
  
	it "should respond with no feed items when there are no updates" do
		Rails.logger.debug("\n\nfeed update test #2\n\n")
	
		earlier_feed_item = generate_feed_item(@user)
		sleep(1.1)
		latest_feed_item = generate_feed_item(@user)
		
		@user.feed_after(latest_feed_item.updated_at + 1.seconds).should be_empty
	end
	
	it "should respond with the correct feed items when there are updates" do
		Rails.logger.debug("\n\nfeed update test #3\n\n")
	
		earlier_feed_item = generate_feed_item(@user)
		sleep(1.1)
		later_feed_item = generate_feed_item(@user)
		sleep(1.1)
		latest_feed_item = generate_feed_item(@user)
		
		@user.feed_after(earlier_feed_item.updated_at + 1.seconds).should_not include(earlier_feed_item)
		@user.feed_after(earlier_feed_item.updated_at).should include(later_feed_item)
		@user.feed_after(earlier_feed_item.updated_at).should include(latest_feed_item)
		@user.feed_after(later_feed_item.updated_at).should include(latest_feed_item)
	end
  end
  
  # Testing pool update responds correctly to different update times
  describe "pool update" do
	before { @user.save }  
  
	it "should respond with nil when the input is nil" do
		@user.pool_after(nil).should be_nil
	end
	
	it "should respond with no pool items when there are no updates" do
		earlier_pool_item = generate_pool_item(@user)
		sleep(1.1)
		later_pool_item = generate_pool_item(@user)
		
		@user.pool_after(later_pool_item.updated_at + 1.seconds).should be_empty
	end
	
	it "should respond with the correct pool items when there are updates" do
		earlier_pool_item = generate_pool_item(@user)
		sleep(1.1)
		later_pool_item = generate_pool_item(@user)
		sleep(1.1)
		latest_pool_item = generate_pool_item(@user)
		
		@user.pool_after(later_pool_item.updated_at).should include(latest_pool_item)
		@user.pool_after(earlier_pool_item.updated_at + 1.seconds).should_not include(earlier_pool_item)
		@user.pool_after(earlier_pool_item.updated_at).should include(later_pool_item)
		@user.pool_after(earlier_pool_item.updated_at).should include(latest_pool_item)
	end
  end
  
  # Testing full text search on the columns of the user relation
  describe "full text search" do	
	it "should respond with nil when the input is nil" do
		User.text_search(nil).should be_nil
	end
	
	it "should respond with the correct outputs on the name field" do
		# UNTESTED
	end
	
	it "should respond with the correct outputs on the email field" do
		# UNTESTED
	end
  end
  
  # Testing friend request that are sent to this user are received
  describe "received friend requests" do
	before { @user.save }
  
	it "should show no received friend requests when there are none" do
		@user.received_friend_requests.should be_empty
	end
	
	it "should correctly show the pending received friend requests" do
		friend = FactoryGirl.create(:user)
		
		friend.friend_request(@user)
		
		@user.received_friend_requests.should include(friend)
	end
  end
  
  # Testing friend requests sent from this user are received
  describe "sent friend requests" do
	before { @user.save }
  
	it "should show no sent friend requests when there are none" do
		@user.sent_friend_requests.should be_empty
	end
	
	it "should correctly show the sent friend requests" do
		friend = FactoryGirl.create(:user)
		
		@user.friend_request(friend)
		
		@user.sent_friend_requests.should include(friend)
	end
  end
  
  # Testing the functionality that checks whether two users are friends
  describe "friends checking" do
	before { @user.save }
	
	it "should correctly show that two people are friends" do
		friend = FactoryGirl.create(:user)
		
		make_friends(@user, friend)
		
		@user.friends?(friend).should be_true
		friend.friends?(@user).should be_true
	end
	
	it "should correctly show that two people are not friends" do
		friend_requestee = FactoryGirl.create(:user)
		
		# Testing case when someone else friend requests user
		@friend_requester.friend_request(@user)
		
		@user.friends?(@friend_requester).should be_false
		@friend_requester.friends?(@user).should be_false
		
		# Testing case when user friend requests someone else
		@user.friend_request(friend_requestee)
		
		@user.friends?(friend_requestee).should be_false
		friend_requestee.friends?(@user).should be_false
		
		# Testing case when users do not know each other at all
		@random_user.friends?(@user).should be_false
		@user.friends?(@random_user).should be_false
	end
  end
  
  describe "ignoring friend requests" do
	before { @user.save }
  
	it "should not allow a user to ignore another user if there is no pending friend request between them" do
		Rails.logger.debug("\n\nignore friend requests test #1\n\n")
	
		# Case when the two users are strangers
		@user.ignore(@random_user).should be_false
		
		# Case when the requester tries to ignore the request sent
		
		@friend_requester.friend_request(@user)
		
		@friend_requester.ignore(@user).should be_false
	end
	
	it "should allow a user to ignore another user if there is a pending friend request between them" do
		Rails.logger.debug("\n\nignore friend requests test #2\n\n")
		
		# When there is a pending friend request between them
		
		@friend_requester.friend_request(@user)
		
		@user.ignore(@friend_requester).should be_true
	end
  end
  
  describe "friends" do
	before { @user.save }
	
	it "should not display any results if the user does not have any friends" do
		# Case when there is nothing between them
		@user.friends.should_not include(@random_user)
		@random_user.friends.should_not include(@user)
	
		# Case when there is a friend request between them
		
		@friend_requester.friend_request(@user)
		
		@user.friends.should_not include(@friend_requester)
		@friend_requester.friends.should_not include(@user)
	end
	
	it "should displays the friends that the user has" do
		make_friends(@user, @friend)
		
		@user.friends.should include(@friend)
		@friend.friends.should include(@user)
	end
  end
  
  describe "get relationship" do
	before { @user.save }
	
	it "should respond with nil when given nil" do
		@user.get_relationship(nil).should be_nil
	end
	
	it "should respond with pending correctly" do
		
		@friend_requester.friend_request(@user)
		
		@user.get_relationship(@friend_requester).should_not be_nil
		@friend_requester.get_relationship(@user).should_not be_nil
	end
	
	it "should respond with ignore correctly" do
		
		@friend_requester.friend_request(@user)
		@user.ignore(@friend_requester)
		
		@user.get_relationship(@friend_requester).should_not be_nil
		@friend_requester.get_relationship(@user).should_not be_nil
	end
	
	it "should respond with friends correctly" do
		make_friends(@user, @friend)
		
		@user.get_relationship(@friend).should_not be_nil
		@friend.get_relationship(@user).should_not be_nil
	end
  end
  
  describe "pending check" do
	before { @user.save }
	
	it "should respond with false if there is no pending relationship" do
		# Case where input is nil
		@user.pending?(nil).should be_false
		
		# Case where friend request is ignored
		
		@friend_requester.friend_request(@user)
		
		@user.ignore(@friend_requester)
		
		@friend_requester.pending?(@user).should be_false
		@user.pending?(@friend_requester).should be_false
		
		# Case where two users are friends
		make_friends(@user, @friend)
		
		@user.pending?(@friend).should be_false
		@friend.pending?(@user).should be_false
	end
	
	it "should respond with true if there is a pending relationship" do
		
		@friend_requester.friend_request(@user)
		
		@friend_requester.pending?(@user).should be_true
		@user.pending?(@friend_requester).should be_false
	end
  end
  
  describe "suggested friends" do
	before { @user.save }
	
	it "should give an empty array if the user has no friends" do
		@user.suggested_friends.should be_empty
	end
	
	it "should give an empty array if the user's friends don't have friends" do
		generate_friends(@user, 5)
		
		@user.suggested_friends.should be_empty
	end
  end
  
  describe "friend requesting" do
	before { @user.save }
	
	it "should respond with nil if the input is nil" do
		@user.friend_request(nil).should be_nil
	end
	
	it "should not allow users to send friend requests if there is already a relationship between the two users" do
		# Case where a friend request has already been made
		
		@friend_requester.friend_request(@user)
		
		@friend_requester.friend_request(@user).should be_false
		@user.friend_request(@friend_requester).should be_false
		
		# Case where users are friends
		make_friends(@user, @friend)
		
		@user.friend_request(@friend).should be_false
		@friend.friend_request(@user).should be_false
		
		# Case where the friend request was ignored
		ignored_user = FactoryGirl.create(:user)
		ignored_user.friend_request(@user)
		@user.ignore(ignored_user)
		
		ignored_user.friend_request(@user).should be_false
		@user.friend_request(ignored_user).should be_false
	end
	
	it "should allow users to send friend requests correctly" do
		@user.friend_request(@random_user).should be_true
	end
  end
  
  describe "friend accepting" do
	before { @user.save }
	
	it "should respond with nil if the input is nil" do
		@user.accept_friend(nil).should be_nil
	end
	
	it "should not allow users to accept friends if there is no friend request between the two users" do
		# Case where the two users do not know each other
		
		
		@user.accept_friend(@random_user).should be_false
		
		# Case where the user who sent a friend request is trying to make it accept
		
		@friend_requester.friend_request(@user)
			
		@friend_requester.accept_friend(@user).should be_false
		
		# Case where the friend request was ignored
		ignored_user = FactoryGirl.create(:user)
		ignored_user.friend_request(@user)
		@user.ignore(ignored_user)
		
		ignored_user.accept_friend(@user).should be_false
		
		# Case where the two users are already friends
		make_friends(@user, @friend)
		
		@user.accept_friend(@friend).should be_false
	end
	
	it "should allow users to accept friends correctly" do
		# Case of a standard request
		
		@friend_requester.friend_request(@user)
		
		@user.accept_friend(@friend_requester).should be_true
		
		# Case where user ignores, and then accepts
		ignored_user = FactoryGirl.create(:user)
		ignored_user.friend_request(@user)
		
		@user.ignore(ignored_user)
		
		@user.accept_friend(ignored_user).should be_true
	end
  end
  
  describe "participating in an event" do
	before { @user.save }
	
	it "should respond with nil if the input is nil" do
		@user.participate(nil).should be_nil
	end
	
	it "should not allow users to participate in microposts for which they are not friends with the user" do
		generate_microposts(@user, 3)
		
		@random_user.participate(@user.microposts.first).should be_false
	end
	
	it "should not allow users to participate in microposts in the past" do
		micropost = FactoryGirl.build(:finished_micropost, user: @user)
		micropost.save(validate: false)
		
		make_friends(@user, @friend)
		
		@friend.participate(micropost).should be_false
	end
	
	it "should allow users to participate in microposts that are in progress" do
		micropost = FactoryGirl.build(:in_progress_micropost, user: @user)
		micropost.save(validate: false)
		
		make_friends(@user, @friend)
		
		@friend.participate(micropost).should be_true
	end
	
	it "should allow users to participate in their friends microposts" do
		make_friends(@user, @friend)
		
		generate_microposts(@user , 3)
		
		@friend.participate(@user.microposts.first).should be_true
	end
  end
  
  describe "checking participation in an event" do
	before { @user.save }
	
	it "should respond with nil if the input is nil" do
		@user.participating?(nil).should be_nil
	end
	
	it "should respond with the correct check for participation in an event" do
		make_friends(@friend, @user)
	
		generate_microposts(@user, 4)
		
		# Case where user should be participating in his own micropost
		@user.participating?(@user.microposts.first).should be_true
		
		# Case where a friend is participating in one of the user's microposts
		@friend.participate(@user.microposts.first)
		@friend.participating?(@user.microposts.first).should be_true
		
		@friend.participating?(@user.microposts.last).should be_false
	end
  end
  
  describe "unparticipating in an event" do
	before { @user.save } 
  
	it "should respond with nil if the input is nil" do
		@user.unparticipate(nil).should be_nil
	end
	
	it "should not allow users to unparticipate from microposts they are not participating in" do
		generate_microposts(@user, 3)
		
		@random_user.unparticipate(@user.microposts.first).should be_false
	end
	
	it "should not allow users to unparticipate from their own events" do
		generate_microposts(@user, 3)
		
		@user.unparticipate(@user.microposts.first).should be_false
	end
	
	it "should correctly allow users to unparticipate from microposts they are participating in" do
		make_friends(@user, @friend)
		
		generate_microposts(@user, 3)
		
		@friend.participate(@user.microposts.first)
		@friend.unparticipate(@user.microposts.first).should be_true
		
		@friend.participating?(@user.microposts.first).should be_false
	end
  end
  
  describe "checking has participations" do
	before { @user.save }
	
	it "should correctly display when the user has no participations" do
		@user.has_participations?.should be_false
	end
	
	it "should correctly display when the user has participations" do
		make_friends(@user, @friend)
		
		expect do
			generate_microposts(@user, 3)
		end.to change{ @user.has_participations? }.from(false).to(true)
		
		expect do
			@friend.participate(@user.microposts.first)
		end.to change{ @friend.has_participations? }.from(false).to(true)
	end
  end
  
  describe "checking has future participations" do
	before { @user.save }
	
	it "should correctly display when the user has no future participations" do
		@user.has_future_participations?.should be_false
		
		FactoryGirl.create(:past_micropost, user: @user)
		
		@user.has_future_participations?.should be_false
	end
	
	it "should correctly display when the user has future participations" do
		make_friends(@user, @friend)
		generate_microposts(@user, 3)
		
		# Case of user participating in own event
		@user.has_future_participations?.should be_true
		
		# Case of a friend participating in user's event
		@friend.participate(@user.microposts.first)
		@friend.has_future_participations?.should be_true
	end
  end
  
  describe "retrieving future participations" do
	before { @user.save }
	
	it "should correctly return an empty list if the user has no future participations" do
		@user.future_participations.should be_empty
	end
	
	it "should correctly display the user's future participations when they exist" do
		make_friends(@user, @friend)
		
		expect do
			generate_microposts(@user, 3)
		end.to change{ @user.future_participations.count }.by(3)
		
		expect do
			@friend.participate(@user.microposts.first)
		end.to change{ @friend.future_participations.count }.by(1)
	end
  end
  
  describe "common participations" do
	before { @user.save }
	
	it "should respond with an empty list if the input user is nil" do
		@user.common_participations(nil).should be_empty
	end
	
	it "should respond with an empty list if the two users are not friends" do
		@user.common_participations(@friend).should be_empty
	end
	
	it "should respond with an empty list if the two users are friends but have no common participations" do
		make_friends(@user, @friend)
		
		generate_microposts(@user, 3)
		generate_microposts(@friend, 3)
		
		@user.common_participations(@friend).should be_empty
		@friend.common_participations(@user).should be_empty
	end
	
	it "should respond with the users own future participations if the input user is himself" do
		generate_microposts(@user, 3)
		
		@user.common_participations(@user).should == @user.future_participations
	end
	
	it "should respond correctly with the two users mutual participations if everything is valid" do
		make_friends(@user, @friend)
		
		generate_microposts(@user, 3)
		
		@friend.participate(@user.microposts.first)

		@friend.future_participations.should include(@user.microposts.first)
			
		@friend.common_participations(@user).should include(@user.microposts.first)
		@user.common_participations(@friend).should include(@user.microposts.first)
	end
  end
  
  describe "notifications" do
	before { @user.save }
  
	it "should grab up to 10 notifications if the number of unread notifications does not exceed 10" do
		unread_notifications = generate_unread_notifications(@user, 9)
		read_notifications = generate_read_notifications(@user, 5)
		
		# Testing Generator Utitility Functions
		#unread_notifications.count.should == 9
		#read_notifications.count.should == 5
		
		notifications = @user.retrieve_notifications
		correct_notifications = unread_notifications.reverse!
		correct_notifications << read_notifications.last
		
		correct_notifications.count.should == 10
		notifications.count.should == 10
		
		notifications.should == correct_notifications
	end
	
	it "should grab all unread notifications otherwise" do
		unread_notifications = generate_unread_notifications(@user, 11)
		read_notifications = generate_read_notifications(@user, 5)
		
		notifications = @user.retrieve_notifications
		notifications.should == unread_notifications.reverse!
		
		notifications.count.should == 11
	end
  end
  
  describe "older notifications" do
	before { @user.save }
  
	it "should receive 10 older notifications if there are >= 10 older notifications" do
		read_notifications = generate_read_notifications(@user, 11)
		
		notifications = @user.older_notifications(read_notifications.last.id)
		notifications.should == read_notifications[0..9].reverse
		
		notifications.count.should == 10
	end
	
	it "should receive all remaining notifications if there are < 10 older notifications" do
		read_notifications = generate_read_notifications(@user, 10)
		
		notifications = @user.older_notifications(read_notifications.last.id)
		notifications.should == read_notifications[0..8].reverse
		
		notifications.count.should == 9
	end
  end
	
  describe "crop profile" do
	# UNTESTED
  end
  
  describe "cropping check" do
	# UNTESTED
  end
  
  describe "avatar geometry" do
	# UNTESTED
  end
end  