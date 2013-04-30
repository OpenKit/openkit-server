OKDashboard::Application.routes.draw do

  resources :oauth_clients

  match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request

  match '/oauth/token',         :to => 'oauth#token',         :as => :token

  match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token

  match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token

  match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize

  match '/oauth',               :to => 'oauth#index',         :as => :oauth

  # In the dashboard, the @app is set off of its id, which is part of the
  # request path.  When using the API, the app_key is used instead, and is
  # passed as a json param.
  resources :apps do
    resources :leaderboards  # Dash
    resources :achievements  # Dash
  end

  # API
  resources :leaderboards, :only => [:index, :create]
  resources :achievements, :only => [:index, :create]
  match "achievements/facebook",          to: "achievements#facebook",  via: :get

  resources :change_password, :only => [:new, :create]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :users
  resources :scores, :only => [:create, :index, :show, :destroy]
  resources :achievement_scores, :only => [:create, :destroy]


  # API only
  match "best_scores",          to: "best_scores#index",  via: :get
  match "best_scores/user",     to: "best_scores#user",   via: :get

  resources :developers,          :only => [:edit, :update, :show, :new, :create]
  resources :developer_sessions,  :only => [:create]
  match "developer_sessions",     :to => "developer_sessions#destroy", :as => :logout, :via => :delete
  match "developer_sessions/new", :to => "developer_sessions#new",    :as => :login, :via => :get

  match "developer_data",      to: "developer_data#create",  via: :post,   :as => :developer_data   # API only
  match "developer_data",      to: "developer_data#index",   via: :get,    :as => :developer_data   # Dashboard only
  # match "developer_data/:id",  to: "developer_data#destroy", via: :delete, :as => :developer_data   # Dashboard only
  match "developer_data/:id",  to: "developer_data#show",    via: :get,    :as => :developer_data   # API only


  # Special request to purge end to end test data
  match "/purge_test_data", to: "apps#purge_test_data", via: :delete

  root :to => 'apps#index'
end
