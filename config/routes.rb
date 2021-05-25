Rails.application.routes.draw do
  root to: 'toppages#index'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'signup', to: 'users#new'
  delete 'destroy', to: 'songs#destroy'
  resources :users, only: [:new, :create]
  resources :songs, only: [:index] do
      collection { post :import }
      collection { post :search }
      collection { post :index_serch}
  end
  resources :chords, only: [:index]
end