OKDashboard::Application.routes.draw do

  scope :module => :api, :defaults => {:format => :json} do

    # 1.0 API
    default_api_routes =-> do
      resources :users,                   only:  [:create, :update]
      resources :achievements,            only:  [:create, :index]
      resources :scores,                  only:  [:create, :show]
      resources :achievement_scores,      only:  [:create]
      resources :leaderboards,            only:  [:create, :index, :show] do
        resources :challenges,            only:  [:create]
      end
      resources :features,                only:  [:index]

      match "client_sessions",            to: "client_sessions#create",  via: :post
      match "best_scores",                to: "best_scores#index",       via: :get
      match "best_scores/user",           to: "best_scores#user",        via: :get
      match "best_scores/social",         to: "best_scores#social",      via: :post
      match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
    end

    constraints :subdomain => /^$|(?:beta-)?(?:api|sandbox|local)/ do
      namespace :v1, &default_api_routes
      scope :module => :v1, &default_api_routes
    end


    # 0.9 API
    scope :module => :v09 do
      constraints :subdomain => 'pivvot' do
        resources :users,                   only:  [:create, :update]
        resources :achievements,            only:  [:create, :index]
        resources :scores,                  only:  [:create, :show]
        resources :achievement_scores,      only:  [:create]
        resources :leaderboards,            only:  [:create, :index, :show]

        match "best_scores",                to: "best_scores#index",       via: :get
        match "best_scores/user",           to: "best_scores#user",        via: :get
        match "best_scores/social",         to: "best_scores#social",      via: :post
        match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
      end
    end

    # 0.8 API
    scope :module => :v08 do
      constraints :subdomain => 'stage' do
        resources :users,                   only:  [:create, :update]
        resources :achievements,            only:  [:create, :index]
        resources :scores,                  only:  [:create, :show]
        resources :achievement_scores,      only:  [:create]
        resources :leaderboards,            only:  [:create, :index]

        match "best_scores",                to: "best_scores#index",       via: :get
        match "best_scores/user",           to: "best_scores#user",        via: :get
        match "best_scores/social",         to: "best_scores#social",      via: :post
        match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
      end
    end
  end


  scope :module => :dashboard do
    constraints :subdomain => /^(developer|beta-developer)$/ do

      resources :change_password,         only:  [:new, :create]
      resources :password_resets,         only:  [:new, :create, :edit, :update]
      resources :scores,                  only:  [:destroy]
      resources :achievement_scores,      only:  [:destroy]
      resources :developers,              only:  [:new, :create, :edit, :update, :show]
      resources :developer_sessions,      only:  [:create]
      resources :apps do
        resources :leaderboards do
          delete :delete_sandbox_scores
        end
        resources :achievements
        resource :sandbox_push_cert,          only: [:new, :create, :destroy]
        resource :production_push_cert,       only: [:new, :create, :destroy]

        match "sandbox_push_cert/test_project",   to: "sandbox_push_certs#test_project",  as: :sandbox_test_project,           via: :get
        match "sandbox_push_cert/test_push",      to: "sandbox_push_certs#test_push",     as: :sandbox_test_push,              via: [:get, :post]

        match "push_notes",  to: "push_notes#info",  as: :push_notes,  via: :get
      end

      resources :turns, only: [:new, :create]

      match "developer_sessions",         to: "developer_sessions#destroy",  as: :logout,           via: :delete
      match "developer_sessions/new",     to: "developer_sessions#new",      as: :login,            via: :get
      root :to => 'apps#index'
    end
  end

  match '/404',  constraints: {:format => :json}, to: proc {|env| [404, {}, [{message: "Sorry, that doesn't exist."}.to_json]]}
  match '/500',  constraints: {:format => :json}, to: proc {|env| [500, {}, [{message: "Internal Server Error."}.to_json]]}

  # Catch all.
  match '*path', constraints: {:format => :json}, to: proc {|env| [404, {}, [{message: "Nothing exists at that path."}.to_json]]}
end
