Rails.application.routes.draw do
  devise_for :customers

  root 'orders#index'

  get :analytics, controller: :orders
  get :frequencies, controller: :orders
  get :recurrences, controller: :orders
end
