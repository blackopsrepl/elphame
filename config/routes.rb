Rails.application.routes.draw do
  # Authentication
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # API endpoints
  namespace :api do
    resources :users, only: [ :index ]
  end

  # Admin dashboard (Administrate)
  namespace :admin do
    root to: "dashboard#index"
    resources :realms
    resources :discussions do
      member do
        post :pin
        post :boost
      end
      resources :thread_labels, only: [ :create, :destroy ]
    end
    resources :posts, only: [ :index, :show, :destroy ]
    resources :users
    resources :star_ratings, only: [ :index, :show ]
    resources :labels
    resources :thread_labels
    resources :admin_actions, only: [ :index, :show ]
  end

  root "realms#index"

  # Global timeline across all realms
  get "timeline", to: "timeline#index"

  resources :realms, only: [ :index, :show ], param: :slug do
    resources :discussions, only: [ :index, :new, :create ]
  end

  resources :discussions, only: [ :show, :edit, :update, :destroy ] do
    resources :posts, only: [ :create ]

    # Label management
    resources :thread_labels, only: [ :create, :destroy ]

    # Curation actions
    member do
      post :pin
      post :boost
    end
  end

  resources :posts, only: [ :edit, :update, :destroy ] do
    # Star ratings
    resource :star_rating, only: [ :show, :create, :destroy ]
  end

  # Agent subscription
  get "skill", to: "skill#show", as: :skill, defaults: { format: :text }
  post "join", to: "join#create", as: :join

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
