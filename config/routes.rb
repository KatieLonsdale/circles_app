Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "home#index"

  
  namespace :api do
    namespace :v0 do
      resources :sessions, only: [:create]
      resources :users do
        resources :circles, only: [:index, :create, :destroy], module: :users do
          resources :circle_members, only: [:create, :destroy], module: :circles
          resources :posts, only: [:index, :create, :update, :destroy], module: :circles do
            resources :comments, only: [:index, :create, :show, :update, :destroy], module: :posts
          end
        end
        resources :friendships, only: [:index, :create, :destroy] do
          collection do
            get :pending
          end
        end
      end
      resources :circles, only: [:index, :show]
    end
  end

  # custom routes
  get "api/v0/users/:id/newsfeed", to: "api/v0/users#newsfeed"
  post "api/v0/users/authenticate", to: "api/v0/users#authenticate"
  
  # Friendship custom routes
  patch "api/v0/users/:user_id/friendships/:id/accept", to: "api/v0/friendships#accept"
  patch "api/v0/users/:user_id/friendships/:id/reject", to: "api/v0/friendships#reject"
end
