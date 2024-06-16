Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v0 do
      resources :users do
        resources :circles, only: [:index, :create, :destroy], module: :users do
          resources :circle_members, only: [:create, :destroy], module: :circles
        end
      end
      resources :circles, only: [:index, :show] do
        resources :posts, only: [:index, :create, :update, :destroy], module: :circles
      end
    end
  end
end
