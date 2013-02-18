class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include RelationshipsHelper
  include MicropostsHelper
  include CropHelper
  include NotificationsHelper
  include CharacteristicsAppHelper
  include GoogleHelper
  include ProposalsHelper
  include PollsHelper
  include PostsHelper
  include BetaHelper
  include TimeHelper
  
  def protect_against_forgery?
	  unless request.format.mobile?
		super
	  end
  end
end
