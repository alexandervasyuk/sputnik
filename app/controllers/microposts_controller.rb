require 'csv'

class MicropostsController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: :destroy
  
  respond_to :html, :js

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    @micropost.invitees = {}
    if params[:micropost][:time][0..1] == "at"
      Time.use_zone(user_timezone) do
       @micropost.time = Time.zone.parse(params[:micropost][:time])
      end
    else
      Time.use_zone(user_timezone) do
        Chronic.time_class = Time.zone
        @micropost.time = Chronic.parse(params[:micropost][:time])
      end
    end
    if @micropost.save
      current_user.participate!(@micropost)
      redirect_to root_url
    else
      if !params[:micropost][:time].empty? and !Chronic.parse(params[:micropost][:time])
        @micropost.errors[:time].clear
        @micropost.errors.add(:time, "needs to follow this format: 4:15 pm, tomorrow 3am, in 10 min, in 2 days, 1:14 pm 15 Nov ")
      end
      @feed_items = current_user.feed
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to :back
  end

  def edit
    @micropost = Micropost.find(params[:id])
  end

  def update
    @micropost = Micropost.find(params[:id])

    if params[:micropost][:time].empty?
      render 'edit'
      return
    end

    # if params[:micropost][:time][0..1] == "at"
    #   @micropost.time = Time.parse(params[:micropost][:time])
    # els
    if  !Chronic.parse(params[:micropost][:time])
      Time.use_zone(user_timezone) do
        params[:micropost][:time] = Time.zone.parse(params[:micropost][:time])
      end
    else
      Time.use_zone(user_timezone) do
        Chronic.time_class = Time.zone
        params[:micropost][:time] = Chronic.parse(params[:micropost][:time])
      end
    end

    if @micropost.update_attributes(params[:micropost])
      #Micropost has been successfully updated
      MicropostMailer.delay.changed(@micropost)
      
      redirect_to(action:'detail', id:@micropost.id)
    else
      render 'edit'
    end
  end
  
  def invite
  	@micropost = Micropost.find(params[:event_id])
  	@invitee = User.find(params[:invitee_id])
  	
  	@micropost.add_to_invited(@invitee)
  	
  	MicropostMailer.delay.invited(@micropost, @invitee)
  	
  	respond_with @invitee
  end
  
  def invite_emails
  	@micropost = Micropost.find(params[:event_id])
  	emails = params[:emails].parse_csv
  	
  	emails.each do |email|
  		user = User.find_by_email(email)
  		
  		#Creates a temporary user
  		if user.nil?
  			user = User.new(email: email, temp:true)
  			user.password_digest = "temporaryuser"
  			user.save!
  		end
  		
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
  
  def invite_redirect
  	@user = User.find(params[:uid])
  	@micropost = Micropost.find(params[:eid])
  	
  	if !@user.nil? && !@micropost.nil?
  		if @user.temp
  			@temp_email = @user.email
  			flash[:message] = "Please sign up to see your invitation"
  			render "users/new"
  		else
  			redirect_to detail_micropost_path(@micropost.id)
  		end
  	else
  		redirect_to root_url, flash: {error: "Invalid invite"}
  	end
  end

  def detail
    @micropost = Micropost.find(params[:id])
    
    if current_user.friends?(@micropost.user)
      @post = current_user.posts.build(micropost_id:params[:id])
      @friends = current_user.friends
      @participants = []
      @micropost.participations.each do |participation|
        @participants << User.find(participation.user_id)
      end
      @post_items = @micropost.posts.reverse!
    else  
      redirect_to :back, :flash => { :error => "You must become friends with the user who created that event to view its details" } 
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

  def correct_user
    @micropost = current_user.microposts.find_by_id(params[:id])
    redirect_to root_url if @micropost.nil?
  end
  
  def illegal_emails
  	redirect_to :back, :flash => { :error => "Invites were not sent because emails were not separated by commas" }
  end 
end