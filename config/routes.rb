Rails.application.routes.draw do
  devise_for :users

  # Landing page específica
  get 'landing', to: 'pages#landing'

  # Root siempre va a landing primero
  root 'pages#landing'

  # Dashboard específico para usuarios logueados
  get 'dashboard', to: 'dashboard#index'

  # resto de tus rutas...
  get "up" => "rails/health#show", as: :rails_health_check
  get :shift_buddy, to: 'pages#shift_buddy'
  get 'stats', to: 'dashboard#stats'

  resources :cases do
    member do
      patch :start_reading
      patch :complete_reading
      post :create_wet_read
      patch :mark_for_teaching
      patch :mark_for_qa
      patch :unmark_for_teaching
      patch :unmark_for_qa
    end
    resources :tasks, except: [:index]
  end

  resources :tasks do
    member do
      patch :complete
      patch :start_timer
      patch :stop_timer
      patch :mark_for_teaching
      patch :mark_for_qa
    end
  end

  resources :teaching_cases, only: [:index, :show]
  resources :qa_cases, only: [:index, :show]
  get 'worklist', to: 'cases#worklist'
  resources :procedures, only: [:index, :show, :update]
end
