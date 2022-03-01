Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :user do
    collection do
      get :login
      post :login
      get :sign_up
      post :sign_up
      get :logout
    end

    member do
      get :user_confirmation
    end
  end

  resources :predictions do
    collection do
      get :table
      get :post
      get :results
    end

    member do
      get :edit_match
      patch :edit_match
      patch :update_match
    end
  end

  resources :leagues do
    collection do
      get :table
      get :results
      get :fixtures
    end

    member do
    end
  end

  resource :saml, controller: 'saml' do
    collection do
      get :init
      post :consume
    end

    member do
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  root to: "user#home"
end
