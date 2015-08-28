class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    if request.env["omniauth.auth"] && request.env["omniauth.auth"]["extra"] && request.env["omniauth.auth"]["extra"]["return_url"]
      return_path = request.env["omniauth.auth"]["extra"]["return_url"]
      raise 'host not allowed in return path' if URI.parse(return_path).host
    end
    return_path  || stored_location_for(resource)  || root_path
  end
end
