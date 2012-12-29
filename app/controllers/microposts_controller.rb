require 'csv'

class MicropostsController < ApplicationController
  #Helper classes
  include NotificationsHelper
  include MicropostsHelper
  include TimeHelper
  
  before_filter :signed_in_user
  before_filter :correct_user, only: [:destroy, :update, :edit]
  before_filter :time_input_parser, only: [:create, :update]
  
  before_filter :detail_prepare, only: [:detail, :mobile_detail]
  
  after_filter :time_parser_error, only: :create
  
  respond_to :html, :js
  
  protect_from_forgery except: :mobile_detail

  #Action responsible for creating a new micropost from form inputs
  #Input interface - content, location, time
  def create
  	@micropost = current_user.microposts.build(params[:micropost])
    @micropost.invitees = {}
  	
    if @micropost.save
      current_user.participate!(@micropost)
	end
      
    @feed_items = current_user.feed
    
    render 'static_pages/home'
  end

  #Action responsible for destroying a micropost from the database
  def destroy
    @micropost.destroy
    redirect_to :back
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
  	
  	if !@micropost.invited(@invitee) && !@invitee.participates?(@micropost)
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
  		if !user.errors.any? && !@micropost.invited(user) && !user.participates?(@micropost)
  			if current_user.get_relationship(user).nil?
  				current_user.friend_request!(user)
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
	params[:time] = params[:micropost][:time]
	params[:micropost][:time] = parse_time(params[:micropost][:time])
  end
  
  #BEFORE FILTER - before filter that prepares the relevant information for detail (web app and mobile)
  def detail_prepare
	@micropost = Micropost.find(params[:id])
    
	@friends = current_user.friends?(@micropost.user)
	
    if @friends
      @post = current_user.posts.build(micropost_id:params[:id])
	  @proposal = current_user.proposals.find_by_micropost_id(params[:id]) || current_user.proposals.build(micropost_id:params[:id])
      @friends = current_user.friends
	  
	  #Gather Participants
      @participants = []
      @micropost.participations.each do |participation|
        @participants << User.find(participation.user_id)
      end
	  
	  #Gather the correct proposals for each category
	  @activity_proposals = @micropost.proposals.select("content, count(*) as content_count").where("content != ?", "").group("content").order("content_count DESC")
	  @location_proposals = @micropost.proposals.select("location, count(*) as location_count").where("location != ?", "").group("location").order("location_count DESC")
	  @time_proposals = @micropost.proposals.select("time, count(*) as time_count").where("time is not null").group("time").order("time_count DESC")
	  
      @post_items = @micropost.posts.reverse!
	end
  end
  
  #AFTER FILTER - Helper method that responds to incorrect format errors and sets the correct error messages for them
  def time_parser_error
  	if !params[:time].empty? and params[:micropost][:time].nil?
	   @micropost.errors[:time].clear
	   @micropost.errors.add(:time, "needs to follow this format: 4:15 pm, tomorrow 3am, in 10 min, in 2 days, 1:14 pm 15 Nov ")
	end
  end
end