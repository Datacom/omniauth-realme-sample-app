Rails.application.routes.draw do

  devise_for :users, controllers: { sessions: "users/sessions", omniauth_callbacks: "realme_users/omniauth_callbacks" }
  post 'realme' => 'omniauth_realme#submit'

  authenticated :user do
    root to: 'protected#index', as: :authenticated_root
  end

  unauthenticated do
    root 'omniauth_realme#signin'
  end

end
