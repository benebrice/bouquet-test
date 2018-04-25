Rails.application.routes.draw do
  devise_for :users
  
  root "orders#index"
end
