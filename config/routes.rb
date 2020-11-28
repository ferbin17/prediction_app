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
  
  root to: "user#home"
end
