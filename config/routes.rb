Rails.application.routes.draw do

  devise_for :users, path: '/', controllers: { sessions: "users/sessions", omniauth_callbacks: "users/omniauth_callbacks" }
  post 'realme' => 'omniauth_realme#submit'

  authenticated :user do
    root to: 'protected#index', as: :authenticated_root
  end

  unauthenticated do
    root 'omniauth_realme#signin'
  end

end
