Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    confirmations: "users/confirmations"
  }, skip: [:registrations]

  as :user do
    get "/users/profile/edit" => "users/registrations#edit", as: :edit_user_registration
    patch "/users/profile" => "users/registrations#update", as: :user_registration
  end

  get "/password_setup", to: "users/password_setup#edit", as: :password_setup
  patch "/password_setup", to: "users/password_setup#update"

  patch "/theme", to: "themes#update"

  root "tarfs#index"

  resources :tarfs do
    resources :comments, only: [:create, :destroy], controller: "tarfs/comments"
    resources :tarf_folders, only: [:create, :destroy], controller: "tarfs/tarf_folders"
    resources :tarf_attachments, only: [:create, :destroy], controller: "tarfs/tarf_attachments"
    member do
      patch :resolve
      patch :reopen
    end
  end

  namespace :admin do
    root "dashboard#index"
    resources :users do
      member do
        post :resend_confirmation
        patch :toggle_active
      end
    end
    resources :dealers
    resources :dealer_groups
    resources :byd_models
    resources :system_settings, only: [:index] do
      collection do
        patch :update_settings
        post :test_email
        post :test_aws
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
