class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include RelationshipsHelper
  include CropHelper
  include NotificationsHelper
  include GoogleHelper
  include ProposalsHelper
  include BetaHelper
  
  def protect_against_forgery?
	  unless request.format.mobile?
		super
	  end
  end
end
