Rails.application.routes.draw do
  namespace :api do
    # Assets + Assignments
    resources :assets do
      resources :asset_assignments, only: [:index, :create] do
        member { patch :close }   # unassign
      end
    end

    # Users (admin only)
    resources :users, only: [:create, :index]

    # Current logged-in user
    get "me", to: "users#me"
  end
end