Rails.application.routes.draw do
  root "repositories#index"

  resources :repositories
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post 'repositories/update_all_releases' => 'repositories#update_all_releases'
end
