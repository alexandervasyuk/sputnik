FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "John" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"
    temp false

    factory :admin do
      admin true
    end
    
    factory :temp_user do
    	email "temp@temp.com"
		temp true    	
    end
    
    factory :unsaved_user do
    	id 1
    end
  end

  factory :micropost do
    content "Lorem ipsum"
    location "Lorem ipsum"
    time Time.now
    user
    
    factory :unsaved_micropost do 
    	id 1
    end
  end
  
  factory :post do
	content "Lorem ipsum"
	user
	micropost
  end
  
  factory :proposal do
	user
	micropost
	
	factory :content_proposal do
		content "Lorem ipsum"
	end
	
	factory :location_proposal do
		location "California"
	end
	
	factory :time_proposal do
		time Time.now
	end
  end
end