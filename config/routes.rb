Rails.application.routes.draw do
  namespace :api do
    resources :assets do
      resources :asset_assignments, only: [:index, :create]
    end
  end
end