Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  namespace :api do
    namespace :v0 do
      resources :users do
        resources :circles, only: [:index, :create, :destroy], module: :users do
          resources :circle_members, only: [:create, :destroy], module: :circles
          resources :posts, only: [:index, :create, :update, :destroy], module: :circles do
            resources :comments, only: [:index, :create, :show, :update, :destroy], module: :posts
          end
        end
      end
      resources :circles, only: [:index, :show]
    end
  end

  # custom routes
  get "api/v0/users/:id/newsfeed", to: "api/v0/users#newsfeed"
  post "api/v0/users/authenticate", to: "api/v0/users#authenticate"
end
