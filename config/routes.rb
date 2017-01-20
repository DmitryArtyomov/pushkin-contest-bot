Rails.application.routes.draw do
  root 'history#index'
  get 'quiz', to: 'history#index'
  post 'quiz', to: 'quiz#task'
end
