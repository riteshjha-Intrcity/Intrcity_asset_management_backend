Rails.application.routes.draw do
  # Allow CORS preflight requests
  match "*path", to: "application#preflight", via: [ :options ]

  namespace :api do
    # ==============================
    # AUTH
    # ==============================
    post "login", to: "auth#login"
    post "logout", to: "auth#logout"

    # ==============================
    # META
    # ==============================
    get "meta/asset_options", to: "assets#options"

    # ==============================
    # DASHBOARD
    # ==============================
    get "dashboard", to: "dashboard#index"
get "asset_assignments/confirm", to: "asset_assignments#confirm"
    # ==============================
    # ASSETS + ASSIGNMENTS
    # ==============================
    resources :assets do
      resources :asset_assignments, only: [ :index, :create ] do
        member do
          patch :close
        end
      end
    end



    # ==============================
    # USERS
    # ==============================
    resources :users, only: [ :create, :index, :destroy ]
    get "me", to: "users#me"
  end
end
