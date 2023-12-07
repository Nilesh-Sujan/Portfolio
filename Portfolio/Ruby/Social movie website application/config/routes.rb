Rails.application.routes.draw do
  resources :movies
  devise_for :users
  devise_scope :user do
    get '/users/sign_out', to: "devise/sessions#destroy"
  end


  get '/search' => 'home#search'

  post "/button", to: 'home#watched', as: 'button'

  get 'recommendations', to: 'home#recommendations'
  resources :users
  resources :friends
  resources :histories
  root 'home#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
