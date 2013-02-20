class MicropostsController < ApplicationController  
  #Before Filters
  before_filter :signed_in_user
  
  before_filter :destroy_prepare, only: [:destroy]
  before_filter :update_prepare, only: [:update]
  before_filter :detail_prepare, only: [:detail]
  before_filter :invite_prepare, only: [:invite]
  
  # User Filters
  before_filter :friends_with_creator, only: [:detail]
  before_filter :correct_user, only: [:destroy, :update, :edit, :invite]
  
  before_filter :valid_invitee, only: [:invite]
  before_filter :already_participating_in, only: [:invite]
  before_filter :already_invited_to, only: [:invite]
  
  # Time Filters
  before_filter :start_time_input_parser, only: [:create, :update]
  before_filter :time_input_parser, only: [:create, :update]

  before_filter :create_prepare, only: [:create]
  
  #After Filters
  after_filter :destroy_cleanup, only: [:destroy]
  after_filter :update_cleanup, only: [:update]
  after_filter :detail_cleanup, only: [:detail]
  after_filter :create_cleanup, only: [:create]
  after_filter :invite_cleanup, only: [:invite]
  
  #Valid sources
  respond_to :html, :js
  
  #Caches
  #caches_page :detail
  
  #Sweepers
  #cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
  
  #Action responsible for creating a new micropost from form inputs
  def create
	respond_to do |format|
		if @created
			format.html { redirect_to detail_micropost_path(@micropost.id) }
			format.mobile do
				json_response = {status: "success", feed: current_user.mobile_feed, pool: current_user.mobile_pool, created: @micropost.to_mobile}
			
				render json: json_response
			end
		else
			format.html do
				@feed_items = current_user.feed
				@pool_items = @feed_items
		
				render 'static_pages/home'
			end
		end
	end
  end

  #Action responsible for destroying a micropost from the database
  def destroy
	@micropost.destroy
    
	respond_to do |format|
		format.html { redirect_to root_url }
		format.mobile { render json: {status: "success"} }
	end
  end

  #Action responsible for returning the micropost data and populating a form for the user to edit
  def edit
	@micropost = Micropost.find(params[:id])
  end

  #Action that updates the micropost that the user specifies
  def update
	@updated = @micropost.update_attributes(params[:micropost])
  
    if @updated
		respond_to do |format|
			format.html { redirect_to detail_micropost_path(@micropost) }
			format.mobile { render json: {status: "success"} }
			format.js { }
		end
    else
		respond_to do |format|
			format.html { render 'edit' }
			format.mobile { mobile_micropost_errors(@micropost) }
			format.js { }
		end
    end
  end
  
  #This action is triggered when a user hits the invite button on one of his friends
  def invite
	@micropost.add_to_invited(@invitee)
	
	respond_to do |format|
		format.html { }
		format.mobile { render json: {status: "success"} }
		format.js { }
	end
  end
  
  def invite_emails
  	@micropost = Micropost.find(params[:event_id])
  	emails = params[:emails].split(",")
  	
  	#Loop through the emails the user provides
  	emails.each do |email|
  		email.strip!
  		
  		#Attempt to find the user in our system with the given email
  		user = User.find_by_email(email)
  		
  		#Creates a temporary user
  		if user.nil?
  			user = User.new(email: email, temp:true)
  			user.password_digest = "temporaryuser"
  			
  			user.save
  		end
  		
  		#Only invite users that are valid emails and not currently invited and not participating
  		if !user.errors.any? && !@micropost.invited?(user) && !user.participating?(@micropost)
  			if current_user.get_relationship(user).nil?
  				current_user.friend_request(user)
  			end
  			
  			@micropost.add_to_invited(user)
  			
  			MicropostMailer.delay.email_invited(@micropost, user, request.protocol, request.host, request.port)
  		end
  	end
  	
  	redirect_to :back, notice: "Invitations sent successfully!"
  end

  # This action is triggered when the user requests for the information on a single micropost
  def detail
	respond_to do |format|
		format.html do
			@post = current_user.posts.build(micropost_id: params[:id])
			
			@friends = current_user.friends			
		end
		format.mobile do
			json_response = {status:"success", failure_reason: "", micropost: @micropost.to_mobile, polls: @polls.collect { |poll| poll.to_mobile }, replies_data: @post_items.collect { |post_item| post_item.to_mobile } }

			render json: json_response
		end
	end
  end
  
  # This action is triggered when the user wants to receive an update on their feed through AJAX
  def refresh
	to_delete = retrieve_deleted
  
	respond_to do |format|
		format.js do 
			@feed_items = current_user.feed
			
			if params[:num].to_i == @feed_items.count
			  render text: "cancel"
			else
			  render partial:'shared/feed'
			end
		end
			
		format.mobile do
			@new_feed_items = current_user.feed_after(session[:feed_latest])
			
			if !@new_feed_items.empty?
				session[:feed_latest] = @new_feed_items.maximum("updated_at")
			
				updates = []
				
				@new_feed_items.each do |update|
					updates << update.to_mobile
				end
				
				json_response = {status: "success", feed_items: updates, to_delete: to_delete}
				
				render json: json_response
			elsif !to_delete.empty?
				json_response = {status: "success", feed_items: [], to_delete: to_delete}
				
				render json: json_response
			else
				json_response = {status: "failure", feed_items: [], to_delete: to_delete}
				
				render json: json_response
			end
		end
	end
  end

  private

  # Preparation Filters
  
  # BEFORE FILTER - 
  def destroy_prepare
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
  end
  
  # BEFORE FILTER -
  def update_prepare
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
  end
  
  # BEFORE FILTER - before filter that prepares the relevant information for create (web app and mobile)
  def create_prepare
	@micropost = current_user.microposts.build(params[:micropost])
    @micropost.invitees = {}
	
	@created = @micropost.save
  end
  
  def detail_prepare
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
	
	if is_valid_micropost?(@micropost)
		#Reply data
		@post_items = @micropost.posts.reverse!
		
		#Polls
		@polls = @micropost.polls.all
		
		#Gather Participants
		@participants = @micropost.participating_users
	end
  end
  
  def invite_prepare
	@micropost = Micropost.find_by_id(params[:micropost_id])
	
	check_valid_micropost(@micropost)
  end
  
  # Input Filters
  
  # BEFORE FILTER -
  def valid_invitee
	@invitee = User.find_by_id(params[:invitee_id])
	
	check_valid_invitee(@invitee)
  end
  
  # BEFORE FILTER -
  def already_participating_in
	check_user_not_participating_in(@invitee, @micropost)
  end
  
  # BEFORE FILTER - 
  def already_invited_to
	check_user_already_invited_to(@invitee, @micropost)
  end
  
  # BEFORE FILTER - Helper method that checks if the user who is trying to modify the micropost is the owner
  def correct_user
    check_owner_of(@micropost)
  end
  
  # BEFORE FILTER
  def illegal_emails
  	redirect_to :back, :flash => { :error => "Invites were not sent because emails were not separated by commas" }
  end 
  
  # BEFORE FILTER - Helper method that selects and parses the time input according to its syntax for the time field
  def start_time_input_parser
	params[:micropost][:time] = parse_start_time(params[:micropost][:time])
  end
  
  # BEFORE FILTER - Helper method that selects and parses the time input according to its syntax for the end time field
  def time_input_parser
	params[:micropost][:end_time] = parse_end_time(params[:micropost][:end_time])
  end
  
  # BEFORE FILTER - before filter that checks if the current user is friends with the owner of the miropost
  def friends_with_creator
	check_friends_with_creator(current_user.friends?(@micropost.user))
  end
  
  # Cleanup After Filters
  
  # AFTER FILTER - after filter that does the necessary clean up work for the destroy action
  def destroy_cleanup
	add_to_deleted(@micropost)
  end
  
  # AFTER FILTER - after filter that does the necessary clean up work for the update action
  def update_cleanup
	if @updated
		#Micropost has been successfully updated
		update_micropost(@micropost)
	end
  end
  
  # AFTER FILTER
  def detail_cleanup
	set_latest_post(@micropost, @post_items.first)
  end
  
  # AFTER FILTER
  def create_cleanup
	current_user.participate(@micropost)
  end
  
  # AFTER FILTER
  def invite_cleanup
	# Create the notification
	creator_id = @invitee.id
	message = User.find(@micropost.user_id).name + " invited you to '" + @micropost.content + "' happpening."
	link = detail_micropost_path(@micropost.id)
	create_notification(creator_id, message, link)
	
	# Mail it out
	MicropostMailer.delay.invited(@micropost, @invitee)
  end
end