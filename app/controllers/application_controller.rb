class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include UsersHelper
  include RelationshipsHelper
  include CropHelper
  include NotificationsHelper
end
