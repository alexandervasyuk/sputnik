class MicropostsController < ApplicationController  
  #Before Filters
  before_filter :signed_in_user
  
  before_filter :destroy_prepare, only: [:destroy]
  before_filter :update_prepare, only: [:update]
  before_filter :create_prepare_new, only: [:create]
  before_filter :detail_prepare_new, only: [:detail]
  
  before_filter :friends_with_creator, only: [:detail]
  
  before_filter :correct_user, only: [:destroy, :update, :edit]
  
  before_filter :time_input_parser, only: [:create, :update]
  before_filter :detail_prepare, only: [:detail]
  before_filter :create_prepare, only: [:create]
  
  #Valid sources
  respond_to :html, :js
  
  #Caches
  #caches_page :detail
  
  #Sweepers
  #cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
  
  #Action responsible for creating a new micropost from form inputs
  #Input interface - content, location, time
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
	Rails.logger.debug("\n\nDestructing\n\n")
  
	if !@micropost.participations.empty?
		@micropost.participations.each do |participation|
			participation.delete
		end
	end
	
    add_to_deleted(@micropost)
    
	@micropost.destroy
    
	respond_to do |format|
		format.html do
			redirect_to root_url
		end
		
		format.mobile do
			render json: {status: "success", failure_reason: ""}
		end
	end
  end

  #Action responsible for returning the micropost data and populating a form for the user to edit
  def edit
    @micropost = Micropost.find(params[:id])
  end

  #Action that updates the micropost that the user specifies
  def update
    @micropost = Micropost.find(params[:id])

    if @micropost.update_attributes(params[:micropost])
      #Micropost has been successfully updated
      update_micropost(@micropost)
      
      redirect_to(action:'detail', id:@micropost.id)
    else
      render 'edit'
    end
  end
  
  #This action is triggered when a user hits the invite  button on one of his friends
  def invite
  	@micropost = Micropost.find(params[:event_id])
  	@invitee = User.find(params[:invitee_id])
  	
  	if !@micropost.invited?(@invitee) && !@invitee.participating?(@micropost)
	  	@micropost.add_to_invited(@invitee)
	
	    #Creating a notification
	    creator_id = @invitee.id
	    message = User.find(@micropost.user_id).name + " invited you to '" + @micropost.content + "' happpening."
	    link = detail_micropost_path(@micropost.id)
	    create_notification(creator_id, message, link)
	  	MicropostMailer.delay.invited(@micropost, @invitee)
  	end
  	
  	respond_with @invitee
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

  def detail
	respond_to do |format|
		format.html
		format.mobile do
			replies_data = []

			@micropost.posts.each do |post|
				replies_data << post.to_mobile
			end

			json_response = {status:"success", failure_reason: "", micropost: @micropost.to_mobile, polls: @micropost.polls.collect { |poll| poll.to_mobile }, replies_data: replies_data}

			render json: json_response
		end
	end
  end
  
  #Action responsible for rendering an updated user feed
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

  #BEFORE FILTER - Helper method that checks if the user who is trying to modify the micropost is the owner
  def correct_user
	Rails.logger.debug("\n\nChecking Owner\n\n")
	Rails.logger.debug("\n\nMicropost User: #{@micropost.user.id}\n\n")
	Rails.logger.debug("\n\nCurrent User: #{current_user.id}\n\n")
  
    check_owner_of(@micropost)
  end
  
  def illegal_emails
  	redirect_to :back, :flash => { :error => "Invites were not sent because emails were not separated by commas" }
  end 
  
  #BEFORE FILTER - Helper method that selects and parses the time input according to its syntax
  def time_input_parser
	user_time = params[:micropost][:time]
	params[:micropost][:time] = parse_time(params[:micropost][:time]) if !user_time.blank?
  
	end_user_time = params[:micropost][:end_time]
	params[:micropost][:end_time] = parse_time(params[:micropost][:end_time]) if !end_user_time.blank?
  
	@micropost = current_user.microposts.build(params[:micropost])
  
	# Case where the user types something but the text conversion fails
	if (user_time && params[:micropost][:time].nil?) || (end_user_time && params[:micropost][:end_time].nil?)
		respond_to do |format|
			format.html do
			   @micropost.errors[:time].clear
			   @micropost.errors.add(:time, "incorrect time format")
			   
			   render 'static_pages/home'
			end
		   
			format.mobile do
				render json: {status: "failure", failure_reason: "TIME_FORMAT"}
			end
		end
	end
  end
  
  # BEFORE FILTER - 
  def destroy_prepare
	Rails.logger.debug("\n\nDestroy Prepare\n\n")
  
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
  end
  
  def update_prepare
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
  end
  
  def create_prepare_new
	
  end
  
  def detail_prepare_new
	@micropost = Micropost.find_by_id(params[:id])
	
	check_valid_micropost(@micropost)
  end
  
  # BEFORE FILTER - before filter that checks if the current user is friends with the owner of the miropost
  def friends_with_creator
	check_friends_with_creator(current_user.friends?(@micropost.user))
  end
  
  #BEFORE FILTER - before filter that prepares the relevant information for detail (web app and mobile)
  def detail_prepare
	  @post = current_user.posts.build(micropost_id:params[:id])
	  @polls = @micropost.polls.all
	  
	  @friends = current_user.friends
	  
	  #Gather Participants
	  @participants = []
	  @micropost.participations.each do |participation|
		@participants << User.find(participation.user_id)
	  end
	  
	  #Reply data
	  @post_items = @micropost.posts.reverse!
	  
	  set_latest_post(@micropost, @post_items.first)
  end
  
  #BEFORE FILTER - before filter that prepares the relevant information for create (web app and mobile)
  def create_prepare
	@micropost = current_user.microposts.build(params[:micropost])
    @micropost.invitees = {}
	
	if @micropost.save
		@created = true
		current_user.participate(@micropost)
	end
  end
end