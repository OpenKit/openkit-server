OKDashboard::Application.routes.draw do
  resources :apps do
    resources :leaderboards
  end

  resources :leaderboards, :only => [:index]

  resources :change_password, :only => [:new, :create]
  resources :password_resets, :only => [:new, :create, :edit, :update]

  resources :users
  resources :scores, :only => [:create, :index, :show, :destroy]
  
  #Scores custom actions, all API only
  resources :best_scores, :only => [:index]

   
  # If you are running in development, modify the line below to include :new and :create actions,
  # then uncomment the link to new_developer_path in app/views/developer_sessions/new.html.erb
  resources :developers,          :only => [:edit, :update, :show]
  match "__:signup_rand:__",      to: "developers#create",  via: :post, :as => :developers
  match "__:signup_rand:__/new",  to: "developers#new",     via: :get,  :as => :new_developer

  resources :developer_sessions,  :only => [:create]
  match "developer_sessions",     :to => "developer_sessions#destroy", :as => :logout, :via => :delete
  match "developer_sessions/new", :to => "developer_sessions#new",    :as => :login, :via => :get

  match "developer_data",      to: "developer_data#create",  via: :post,   :as => :developer_data   # API only
  match "developer_data",      to: "developer_data#index",   via: :get,    :as => :developer_data   # Dashboard only
  # match "developer_data/:id",  to: "developer_data#destroy", via: :delete, :as => :developer_data   # Dashboard only
  match "developer_data/:id",  to: "developer_data#show",    via: :get,    :as => :developer_data   # API only

  root :to => 'apps#index'
end
