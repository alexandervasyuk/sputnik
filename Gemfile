source 'https://rubygems.org'

gem 'rails', '3.2.8'
gem 'bootstrap-sass', '~> 2.1.1.0'
gem 'bcrypt-ruby', '3.0.1'
gem 'faker', '1.0.1'
gem 'will_paginate', '3.0.3'
#gem 'bootstrap-will_paginate', '0.0.6'
gem 'jquery-rails', '2.0.2'

gem "chronic", "~> 0.8.0"
gem 'paperclip', '~> 3.0'
gem 'remotipart', '~> 1.0'
gem 'rmagick', '2.13.1'
gem 'detect_timezone_rails'
gem 'delayed_job_active_record'
gem "workless", "~> 1.1.1"
gem 'httparty'
gem 'daemons'
gem 'execjs'
gem 'geo_ip'
gem 'newrelic_rpm'

gem 'omniauth-facebook'

group :development, :test do
  gem 'sqlite3', '1.3.5'
  gem 'rspec-rails', '2.11.0'
  gem 'guard-rspec', '1.2.1'
  gem 'guard-spork', '1.2.0'  
  gem 'spork', '0.9.2'
  gem 'pg', '0.14.1'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.5' 
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '1.2.3'
end

group :test do
  gem 'capybara', '1.1.2'
  gem 'factory_girl_rails', '4.1.0'
  gem 'cucumber-rails', '1.2.1', :require => false
  gem 'database_cleaner', '0.7.0'
  # gem 'launchy', '2.1.0'
  # gem 'rb-fsevent', '0.9.1', :require => false
  # gem 'growl', '1.0.3'
end

group :production do
  gem 'pg', '0.14.1'
  gem 'aws-sdk'
end
