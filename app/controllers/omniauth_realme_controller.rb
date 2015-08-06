class OmniauthRealmeController < ApplicationController

  def submit
    redirect_to user_omniauth_authorize_path(:realme, logon_type: application_params[:use_case])
  end

  def signin
    @realme = Realme.new(
                          customer_name: Rails.application.secrets["omniauth_realme"]["customer_name"],
                          app_name: Rails.application.secrets["omniauth_realme"]["app_name"],
                          shared_key: Rails.application.secrets["omniauth_realme"]["shared_key"])
  end

  private

    def application_params
      params.permit(:use_case)
    end
end