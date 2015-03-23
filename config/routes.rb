Rails.application.routes.draw do

  namespace :api do
    resources :tokens, only: [:index, :create]
    resources :history, only: [:index, :create]
  end

  resources :user_authentications, path: '/account/authentications'

  # User profile
  match '/u/:id' => 'users#show', via: [:get]

  # Omniauth
  match '/auth/:provider/callback' => 'user_authentications#create', via: [:get, :post]
  match '/auth/failure' => 'user_authentications#failure', via: [:get, :post]
  match '/auth/:provider' => 'user_authentications#blank', via: [:get], as: :authenticate

  # User Sessions
  get '/login' => 'user_sessions#new', as: :login
  get '/signup' => 'user_sessions#new', as: :signup, welcome: true
  match '/logout' => 'user_sessions#destroy', as: :logout, via: [:get, :post]

  # Static pages routing, use StaticPage to check if exists as constraint
  match '/*page' => 'static_pages#show', as: :static_page, constraints: StaticPage.new, via: [:get]

  root to: 'static_pages#show', page: 'home'

end


ColorCamp::Application.routes.named_routes.url_helpers_module.module_eval do

  {
    # Social Media URLs
    facebook_url:           'https://facebook.com/gleuchweb',
    facebook_profile_url:   'https://facebook.com/gleuch',
    twitter_url:            'https://twitter.com/gleuch',
    twitter_favorites_url:  'https://twitter.com/gleuch/favorites',
    github_url:             'https://github.com/gleuch',
    instagram_url:          'http://instagram.com/gleuch',
    linkedin_url:           'http://www.linkedin.com/in/gleuch',
    google_plus_url:        'https://plus.google.com/100780866870324876908',
    email_url:              'mailto:contact@gleu.ch',

  }.each do |name,url|
    define_method(name){ url }
  end

end