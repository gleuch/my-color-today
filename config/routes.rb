Rails.application.routes.draw do

  namespace :api do
    resources :tokens, only: [:index, :create]
    resources :history, only: [:index, :create]
  end

  resources :user_authentications, path: '/account/authentications'

  # User settings
  match '/settings' => 'users#edit', via: [:get], as: :user_settings
  match '/settings' => 'users#update', via: [:put]

  # User profile
  resources :users, path: '/u', only: [:show], as: :user_profile, constraints: { id: /[A-Za-z0-9\.\-\_]+?/, format: /json/ } do
    get '/:date', action: :show, as: :dated, on: :member
  end

  # Omniauth
  match '/auth/:provider/callback' => 'user_authentications#create', via: [:get, :post]
  match '/auth/failure' => 'user_authentications#failure', via: [:get, :post]
  match '/auth/:provider' => 'user_authentications#blank', via: [:get], as: :authenticate

  # User Sessions
  get '/login' => 'user_sessions#new', as: :login
  get '/signup' => 'user_sessions#new', as: :signup, welcome: true
  match '/logout' => 'user_sessions#destroy', as: :logout, via: [:get, :post]

  # Web Sites
  resources :web_sites, path: '/s', only: [:index, :show], constraints: { id: /[A-Za-z0-9\.\-]+?/, format: /json/} do
    get '/:date', action: :show, as: :dated, on: :member
  end

  # Share success
  match '/share/:id/success' => 'static_pages#show', via: [:get], page: 'share_success', as: :share_success

  # Static pages routing, use StaticPage to check if exists as constraint
  match '/home/:date' => 'static_pages#show', via: [:get], page: 'home', as: :dated_everyone
  match '/*page' => 'static_pages#show', as: :static_page, constraints: StaticPage.new, via: [:get]

  # Specialized shortcodes
  match '/*code' => 'static_pages#short_code', as: :short_code, constraints: ShortCode.new, via: [:get]

  root to: 'static_pages#show', page: 'home'

end


ColorCamp::Application.routes.named_routes.url_helpers_module.module_eval do

  {
    # Social Media URLs
    facebook_url:           'https://facebook.com/mycolortoday',
    twitter_url:            'https://twitter.com/mycolortoday',
    instagram_url:          'http://instagram.com/mycolortoday',
    email_url:              'hello@mycolor.today',
    amazon_book_url:        'javascript:alert("The book will be available soon on Amazon. Check back in a few days.")',
    lulu_book_url:          'javascript:alert("The book will be available soon on Lulu. Check back in a few days.")',
    # amazon_book_url:        '/amazonbook', # short code referral tracking
    # lulu_book_url:          '/lulubook', # short code referral tracking
    link_book_url:          'http://www.linkartcenter.eu/',

  }.each do |name,url|
    define_method(name){ url }
  end

end