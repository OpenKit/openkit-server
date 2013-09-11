OKDashboard::Application.routes.draw do

  scope :module => :api, :defaults => {:format => :json} do

    # 0.8 API
    scope :module => :v0_8 do
      constraints :subdomain => 'stage' do
        resources :users,                   only:  [:create, :update]
        resources :achievements,            only:  [:create, :index]
        resources :scores,                  only:  [:create, :index, :show]
        resources :achievement_scores,      only:  [:create]
        resources :leaderboards,            only:  [:create, :index]

        match "best_scores",                to: "best_scores#index",       via: :get
        match "best_scores/user",           to: "best_scores#user",        via: :get
        match "best_scores/social",         to: "best_scores#social",      via: :post
        match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
      end
    end

    # 0.9 API
    scope :module => :v0_9 do
      constraints :subdomain => 'pivvot' do
        resources :users,                   only:  [:create, :update]
        resources :achievements,            only:  [:create, :index]
        resources :scores,                  only:  [:create, :index, :show]
        resources :achievement_scores,      only:  [:create]
        resources :leaderboards,            only:  [:create, :index, :show]

        match "best_scores",                to: "best_scores#index",       via: :get
        match "best_scores/user",           to: "best_scores#user",        via: :get
        match "best_scores/social",         to: "best_scores#social",      via: :post
        match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
      end
    end

    # 1.0 API
    constraints :subdomain => 'api' do
      namespace :v1 do
        resources :users,                   only:  [:create, :update]
        resources :achievements,            only:  [:create, :index]
        resources :scores,                  only:  [:create, :index, :show]
        resources :achievement_scores,      only:  [:create]
        resources :leaderboards,            only:  [:create, :index, :show] do
          resources :challenges,            only:  [:create]
        end

        match "client_sessions",            to: "client_sessions#create",  via: :post
        match "best_scores",                to: "best_scores#index",       via: :get
        match "best_scores/user",           to: "best_scores#user",        via: :get
        match "best_scores/social",         to: "best_scores#social",      via: :post
        match "/purge_test_data",           to: "apps#purge_test_data",    via: :delete
      end
    end
  end


  scope :module => :dashboard do
    constraints :subdomain => 'developer' do

      resources :change_password,         only:  [:new, :create]
      resources :password_resets,         only:  [:new, :create, :edit, :update]
      resources :scores,                  only:  [:destroy]
      resources :achievement_scores,      only:  [:destroy]
      resources :developers,              only:  [:new, :create, :edit, :update, :show]
      resources :developer_sessions,      only:  [:create]
      resources :apps do
        resources :leaderboards
        resources :achievements
      end

      match "developer_sessions",         to: "developer_sessions#destroy",  as: :logout,           via: :delete
      match "developer_sessions/new",     to: "developer_sessions#new",      as: :login,            via: :get
      match "challenges/info",            to: "challenges#info",             as: :challenges_info,  via: :get
      root :to => 'apps#index'
    end
  end
end
