Rails.application.routes.draw do


  root 'users#index'

  resources :users, except: [:destroy]
  resource :session, only: [:new, :create, :destroy]
  resources :questions, except: [:show, :new]

end
