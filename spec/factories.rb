FactoryGirl.define do
  factory :user do
	sequence(:id) { |n| }
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
	sequence(:id) { |n| }
	user
	micropost
	content "Lorem ipsum"
	location "Lorem ipsum"
	time Time.now
  end
  
  factory :poll do
	sequence(:id) { |n| }
	micropost
  end
  
  factory :characteristic do
	sequence(:id) { |n| }
	micropost
  end
end