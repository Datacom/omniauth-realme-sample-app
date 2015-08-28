class UsersController < ApplicationController
  before_action :realme_authenticate, except: [:landing]

  # Landing for the users since we do not know their ID before we create them after RealMe authentication
  def landing
    redirect_to user_path(current_user) if current_user
  end

  def show
    @user = current_user
  end

  def realme_authenticate
    # Return URL specified by the gem, due to bug in the request.env['omniauth.origin'] value.
    # See: https://github.com/intridea/omniauth/issues/306
    redirect_to user_omniauth_authorize_path(:realme, logon_type: 'assert', return_url: landing_path) unless user_signed_in?
  end
end
