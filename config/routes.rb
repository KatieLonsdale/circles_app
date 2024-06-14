Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v0 do
      resources :users do
        resources :circles, only: [:index, :create, :destroy]
      end
      resources :circles, only: [:index, :show]
    end
  end
end
