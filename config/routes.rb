SolbrainTwitter::Application.routes.draw do
  get "check_burn/index"
  get "check_burn/question_tweets"
  post "check_burn/judge"

  get "tweet_data_acquire/index"
  post "tweet_data_acquire/search"
  post "tweet_data_acquire/add_target"

  get "follow_analysis/index"

  get "profile_analysis/index"

  get "data_acquisition/index"
  get "data_acquisition/delete_my_profile"
  get "data_acquisition/create_or_update_my_profile"
  get "data_acquisition/create_or_update_my_followers"
  get "data_acquisition/create_my_tweet"
  get "data_acquisition/create_my_recently_tweet"
  get "data_acquisition/create_my_retweet"
  get "data_acquisition/create_my_recently_mention"
  get "data_acquisition/create_my_mention"

  get "dashboard/index"

  get "acquire_origin/index"
  post "acquire_origin/acquire_origin_user"

  get 'user_tweet_data/index'
  post 'user_tweet_data/show_tweet_of_acquire_origin'

  get 'test_flotr2/index'


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

  devise_for :users, :controllers => {
      :omniauth_callbacks => "users/omniauth_callbacks"
  }

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'dashboard#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
