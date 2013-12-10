OKDashboard::Application.routes.draw do

  scope :defaults => {:format => :json} do

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

      post 'client_sessions',           to: 'client_sessions#create'
      get 'best_scores',                to: 'best_scores#index'
      get 'best_scores/user',           to: 'best_scores#user'
      post 'best_scores/social',        to: 'best_scores#social'
      delete '/purge_test_data',        to: 'apps#purge_test_data'
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

        get 'best_scores',                to: 'best_scores#index'
        get 'best_scores/user',           to: 'best_scores#user'
        post 'best_scores/social',        to: 'best_scores#social'
        delete '/purge_test_data',        to: 'apps#purge_test_data'
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

        get 'best_scores',                to: 'best_scores#index'
        get 'best_scores/user',           to: 'best_scores#user'
        post 'best_scores/social',        to: 'best_scores#social'
        delete '/purge_test_data',        to: 'apps#purge_test_data'
      end
    end
  end

  match '/404',  via: :all, constraints: {:format => :json}, to: proc {|env| [404, {}, [{message: "Sorry, that doesn't exist."}.to_json]]}
  match '/500',  via: :all, constraints: {:format => :json}, to: proc {|env| [500, {}, [{message: "Internal Server Error."}.to_json]]}

  # Catch all.
  match '*path', via: :all, constraints: {:format => :json}, to: proc {|env| [404, {}, [{message: "Nothing exists at that path."}.to_json]]}
end
