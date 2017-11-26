Rails.application.routes.draw do

  resources :users
  resources :jobs
  root to: 'visitors#index'
  get '/auth/:provider/callback' => 'sessions#create'
  get '/signin'                  => 'sessions#new',     :as => :signin
  get '/signout'                 => 'sessions#destroy', :as => :signout
  get '/auth/failure'            => 'sessions#failure'
  get "/pages/:page"             => "pages#show"

  mount Facebook::Messenger::Server, at: 'bot'

end
