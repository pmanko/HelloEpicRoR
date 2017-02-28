Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'pages#login'

  get 'patient', to: 'pages#patient'

  get 'provider', to: 'pages#provider'

end
