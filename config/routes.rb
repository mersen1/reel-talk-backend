# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "home", to: "home#show"
      get "titles", to: "titles#index"
      get "titles/:media_type/:id", to: "titles#show"
      get "titles/tv/:id/seasons/:season_number", to: "titles#season"
      get "search", to: "search#show"
      get "people/:id", to: "people#show"
      get "configuration", to: "configuration#show"
      get "library", to: "library#index"
      get "custom_lists", to: "custom_lists#index"
      post "custom_lists", to: "custom_lists#create"
      get "shared_lists/:token", to: "custom_lists#shared"
      put "custom_lists/:id", to: "custom_lists#update"
      delete "custom_lists/:id", to: "custom_lists#destroy"
      post "custom_lists/:id/items/:media_type/:title_id", to: "custom_lists#add_item"
      delete "custom_lists/:id/items/:media_type/:title_id", to: "custom_lists#remove_item"
      get "guest", to: "guests#show"
      get "recent_views", to: "recent_views#index"
      put "recent_views/:media_type/:id", to: "recent_views#update"
      put "library/:media_type/:id", to: "library#update"
      delete "library/:media_type/:id", to: "library#destroy"
      get "titles/:media_type/:id/comments", to: "comments#index"
      post "titles/:media_type/:id/comments", to: "comments#create"
      get "titles/tv/:id/seasons/:season_number/episodes/:episode_number/comments", to: "comments#index", defaults: { media_type: "tv" }
      post "titles/tv/:id/seasons/:season_number/episodes/:episode_number/comments", to: "comments#create", defaults: { media_type: "tv" }
      put "comments/:id/like", to: "comments#like"
    end
  end

  get "lists/:token", to: "public_lists#show"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
