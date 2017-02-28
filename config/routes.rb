Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'pages#login'

  get 'patient', to: 'pages#patient', as: :patient

  get 'provider', to: 'pages#provider', as: :provider

  get 'findex', to: 'pages#fhir_index', as: :fhir_index
  get 'flaunch', to: 'pages#fhir_launch', as: :fhir_launch

end