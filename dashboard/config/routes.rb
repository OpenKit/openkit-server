OKDashboard::Application.routes.draw do



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

    get 'sandbox_push_cert/test_project',  to: 'sandbox_push_certs#test_project',  as: :sandbox_test_project
    match 'sandbox_push_cert/test_push',   via: [:get, :post],  to: 'sandbox_push_certs#test_push', as: :sandbox_test_push

    get 'push_notes',  to: 'push_notes#info',  as: :push_notes

    resources :turns, only: [:new, :create]
  end

  delete 'developer_sessions',      to: 'developer_sessions#destroy',  as: :logout
  get 'developer_sessions/new',     to: 'developer_sessions#new',      as: :login
  root :to => 'apps#index'
end
