# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    resources :assets do
      resources :asset_assignments, only: [:index, :create] do
        member do
          patch :close   # /api/assets/:asset_id/asset_assignments/:id/close
        end
      end
    end
  end
end