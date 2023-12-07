Rails.application.routes.draw do
  devise_for :users
  devise_for :views
  resources :contacts, only: [:new, :create]
  get 'event/index'
  root 'event#index'
  get 'contact/index'
  get 'contact', to: 'contact#index'
  post 'request_contact', to: 'contact#request_contact'
  get "event/data", to: "event#data", as: :data
  get "event/db_action", to: "event#db_action", as: :db_action

  # The priority is based upon order of creation: first created -> highest priority.

end
