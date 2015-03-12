Rails.application.routes.draw do

  namespace :api do
    resources :tokens, only: [:show, :create]
    resources :history, only: [:create]
  end

  resources :user_authentications, path: '/account/authentications'

  # Omniauth
  match '/auth/:provider/callback' => 'user_authentications#create', via: [:get, :post]
  match '/auth/failure' => 'user_authentications#failure', via: [:get, :post]
  match '/auth/:provider' => 'user_authentications#blank', via: [:get], as: :authenticate

  # User Sessions
  get '/login' => 'user_sessions#new', as: :login
  match '/logout' => 'user_sessions#destroy', as: :logout, via: [:get, :post]

  # Static pages routing, use StaticPage to check if exists as constraint
  match '/*page' => 'static_pages#show', as: :static_page, constraints: StaticPage.new, via: [:get]

  root to: 'static_pages#show', page: 'home'

end
