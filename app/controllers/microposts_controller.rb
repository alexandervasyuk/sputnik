require 'csv'

class MicropostsController < ApplicationController
  #Helper classes
  include NotificationsHelper
  include MicropostsHelper
  include TimeHelper
  
  #Before Filters
  before_filter :signed_in_user
  before_filter :correct_user, only: [:destroy, :update, :edit]
  before_filter :time_input_parser, only: [:create, :update]
  before_filter :detail_prepare, only: [:detail, :mobile_detail]
  before_filter :create_prepare, only: [:create, :mobile_create]
  
  #Valid sources
  respond_to :html, :js
  
  #Security
  protect_from_forgery except: [:mobile_detail, :mobile_refresh, :mobile_create]
  
  #Caches
  #caches_page :detail
  
  #Sweepers
  #cache_sweeper :event_sweeper, only: [:create, :update, :destroy]
  
  #Action responsible for creating a new micropost from form inputs
  #Input interface - content, location, time
  def create
    if @created
	  redirect_to detail_micropost_path(@micropost.id)
	else 
	  @feed_items = current_user.feed
	  @pool_items = @feed_items
	
	  render 'static_pages/home'
	end
  end
  
  def mobile_create
	if @created
		json_response = {status: "success", created: @micropost.to_mobile}
		
		render json: json_response
	else
		json_response = {status: "failure", created: {}}
		
		render json: json_response
	end
  end

  #Action responsible for destroying a micropost from the database
  def destroy
	if !@micropost.participations.empty?
		@micropost.participations.each do |participation|
			participation.delete
		end
	end
  
    @micropost.destroy
	
    redirect_to root_url
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
    if !@friends
      redirect_to :back, :flash => { :error => "You must become friends with the user who created that event to view its details" } 
    end
  end
  
  def mobile_detail
	if @friends
		replies_data = []
		
		@micropost.posts.each do |post|
			replies_data << mobile_detail_convert(post)
		end
	
		json_response = {status:"success", replies_data: replies_data}
	
		render json: json_response
	else
		json_response = {status: "failure", replies_data: []}
	
		render json: json_response
	end
  end
  
  #Action responsible for rendering an updated user feed
  def refresh
    @feed_items = current_user.feed
    
    if params[:num].to_i == @feed_items.count
      render text: "cancel"
    else
      render partial:'shared/feed'
    end
  end
  
  
  def mobile_refresh
    logger.debug "mobile refresh feed latest: #{session[:feed_latest]}"
	
	@new_feed_items = current_user.feed_after(session[:feed_latest])
	
	logger.debug "\n\n all new feed items: "
	logger.debug @new_feed_items
	
	to_delete = []
	params[:ids].each do |id|
		if !Micropost.exists?(id)
			to_delete << id
		end
	end
	
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

  private

  #BEFORE FILTER - Helper method that checks if the user who is trying to modify the micropost is the owner
  def correct_user
    @micropost = current_user.microposts.find_by_id(params[:id])
    if @micropost.nil?
    	redirect_to root_url, flash: {error: "You cannot access this happpening =P"}
    end
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
	if user_time && params[:micropost][:time].nil?
	   @micropost.errors[:time].clear
	   @micropost.errors.add(:time, "incorrect time format")
	   
	   render 'static_pages/home'
	elsif end_user_time && params[:micropost][:end_time].nil?
	   @micropost.errors[:time].clear
	   @micropost.errors.add(:time, "incorrect time format")
	end
  end
  
  #BEFORE FILTER - before filter that prepares the relevant information for detail (web app and mobile)
  def detail_prepare
	@micropost = Micropost.find(params[:id])
    
	@friends = current_user.friends?(@micropost.user)
	
    if @friends
      @post = current_user.posts.build(micropost_id:params[:id])
	  #@proposal = current_user.proposals.find_by_micropost_id(params[:id]) || current_user.proposals.build(micropost_id:params[:id])
	  @polls = @micropost.polls.all
      
	  @friends = current_user.friends
	  
	  #Gather Participants
      @participants = []
      @micropost.participations.each do |participation|
        @participants << User.find(participation.user_id)
      end
	  
	  #Gather the correct proposals for each category
	  #@location_proposals = @micropost.proposals.select("location, count(*) as location_count").where("location != ?", "").group("location").order("location_count DESC")
	  #@time_proposals = @micropost.proposals.select("time, count(*) as time_count").where("time is not null").group("time").order("time_count DESC")
	  
	  #Reply data
      @post_items = @micropost.posts.reverse!
	end
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