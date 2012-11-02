namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_microposts
    #make_relationships
  end
end

def make_users
  admin = User.create!(name:     "Example User",
                       email:    "example@railstutorial.org",
                       password: "foobar",
                       password_confirmation: "foobar")
  admin.toggle!(:admin)
  99.times do |n|
    name  = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name:     name,
                 email:    email,
                 password: password,
                 password_confirmation: password)
  end
end

def make_microposts
  users = User.all(limit: 6)
  #50.times do
    users.each { |user| 
      content = Faker::Lorem.sentence(5)
      location = Faker::Name.name
      time = Time.now
      user.microposts.create!(content: content, location: location, time: time) 
    }
  #end
end

def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end

def make_participations
  users=User.all[0..5]
  microposts=Micropost.all[0..5]
  users.each do |user|
    microposts.each do |micropost|
      user.participate!(micropost)
    end
  end
end
