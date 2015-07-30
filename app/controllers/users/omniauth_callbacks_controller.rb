class RealmeUsers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def realme
    @realme_user = RealmeUser.from_omniauth(request.env["omniauth.auth"])

    if @realme_user.persisted?
      sign_in_and_redirect @realme_user, :event => :authentication #this will throw if @realme_user is not activated
      set_flash_message(:notice, :success, :kind => "Realme") if is_navigational_format?
    else
      # If for some reason the user cannot be saved
      raise 'RealMe user was not found or created'
    end
  end
end