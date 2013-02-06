# Load the rails application
require File.expand_path('../application', __FILE__)

# Logger
Rails.logger = Logger.new(STDOUT)

# Initialize the rails application
Sputnik::Application.initialize!
