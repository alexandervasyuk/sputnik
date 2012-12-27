Sputnik::Application.routes.draw do
  resources :users do
    member do
      get :following, :followers, :created, :participates
    end
  end

  resources :microposts do 
    member do
      get :detail
    end
  end

  resources :sessions, only: [:new, :create, :destroy]
  resources :participations, only: [:create, :destroy]
  resources :posts, only: [:create, :destroy]
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:create, :update, :destroy]
  resources :password_resets
  resources :proposals, only: [:create, :update, :destroy]
  
  root to: 'static_pages#home'

  match '/signup',  to: 'users#new'
  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete
      
  match '/help',    to: 'static_pages#help'
  match '/friend', to: 'static_pages#friend'
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  match '/terms', to: 'static_pages#terms_conditions'
  match '/privacy', to: 'static_pages#privacy'
  
  match '/search', to: 'static_pages#search'
  
  match '/crop', to: 'static_pages#crop'
  match '/crop/finish', to: 'static_pages#crop_finish'
  
  match '/micropost/refresh', to: 'microposts#refresh'
  match '/micropost/invite', to: 'microposts#invite'
  match '/micropost/invite/emails', to: 'microposts#invite_emails'
  
  match '/micropost/email/invite', to: 'invites#invite_redirect'
  
  match '/post/refresh', to: 'posts#refresh'
  
  match '/crop/image', to: 'static_pages#crop_image_render'

  #Notification update unread to read
  match '/notifications/update_read', to: 'notifications#update_read'
  
  #Notification AJAX Update
  match '/notifications/refresh', to: 'notifications#ajax_update'

  #Mobile routes
  match '/mobile/signin', to: 'sessions#create_mobile'
  match '/mobile/signout', to: 'sessions#destroy_mobile'
  match '/mobile/signup', to: 'users#create_mobile'
  match '/mobile/event_details', to: 'microposts#mobile_detail'
  #match '/microposts/detail/:id', to: 'microposts#detail'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
