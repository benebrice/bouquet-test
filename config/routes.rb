Rails.application.routes.draw do
  devise_for :customers
  
  root "orders#index"
end
