Rails.application.routes.draw do
  mount Apple::App::Site::Association, at: '/'

  root 'home#home'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
end
