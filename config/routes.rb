OKDashboard::Application.routes.draw do
  resources :apps do
    resources :leaderboards
  end

  resources :leaderboards, :only => [:index]

  resources :change_password, :only => [:new, :create]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :users
  resources :scores, :only => [:create, :index, :show, :destroy]

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

  root :to => 'apps#index'
end
