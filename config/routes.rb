Rails.application.routes.draw do
  # Allow CORS preflight requests
  match "*path", to: "application#preflight", via: [:options]
  namespace :api do
  get "meta/asset_options", to: "assets#options"
  end
  namespace :api do
    post "login", to: "auth#login"

    resources :assets do
      resources :asset_assignments, only: [:index, :create] do
        member { patch :close }
      end
    end

    resources :users, only: [:create, :index, :destroy]
    get "me", to: "users#me"
  end
end