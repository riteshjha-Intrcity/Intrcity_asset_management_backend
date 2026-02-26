# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    post "login", to: "auth#login"

    resources :assets do
      resources :asset_assignments, only: [:index, :create] do
        member { patch :close }
      end
    end

    resources :users, only: [:create, :index]
    get "me", to: "users#me"
  end
end