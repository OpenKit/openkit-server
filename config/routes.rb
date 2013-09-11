OKDashboard::Application.routes.draw do
  scope :module => :dashboard do
    constraints subdomain: 'developer' do

      resources :apps do
        resources :leaderboards
        resources :achievements
      end

      resources :change_password, :only => [:new, :create]
      resources :password_resets, :only => [:new, :create, :edit, :update]

      resources :scores, :only => [:destroy]
      resources :achievement_scores, :only => [:destroy]

      resources :developers,          :only => [:edit, :update, :show, :new, :create]
      resources :developer_sessions,  :only => [:create]
      match "developer_sessions",     :to => "developer_sessions#destroy", :as => :logout, :via => :delete
      match "developer_sessions/new", :to => "developer_sessions#new",    :as => :login, :via => :get

      match "challenges/info", to: "challenges#info", via: :get, :as => :challenges_info

      root :to => 'apps#index'
    end
  end

  scope :module => :api, :defaults => {:format => :json} do
    constraints subdomain: 'api' do

      match "client_sessions",  to: "client_sessions#create", via: :post

      resources :users, :only => [:create, :update]
      resources :leaderboards, :only => [:index, :create, :show] do
        resources :challenges, :only => [:create]
      end
      resources :achievements, :only => [:index, :create]

      resources :scores, :only => [:create, :index, :show]
      resources :achievement_scores, :only => [:create]

      match "best_scores",          to: "best_scores#index",  via: :get
      match "best_scores/user",     to: "best_scores#user",   via: :get
      match "best_scores/social",   to: "best_scores#social", via: :post

      # Special request to purge end to end test data
      match "/purge_test_data", to: "apps#purge_test_data", via: :delete
    end
  end

  match "/fun_with_rack", :to => proc {|env| [200, {}, ["Cool!"]]}

end
