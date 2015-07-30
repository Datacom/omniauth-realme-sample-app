class OmniauthRealmeController < ApplicationController
  def submit
    # Actual code for constructing the message and sending to RealMe
    # application = Devise.setup.omniauth

    application = OmniAuth::Realme::Application.new(
                            application_params[:customer_name],
                            application_params[:app_name],
                            Rails.application.secrets["omniauth_realme"]["shared_key"])
    integrator = OmniAuth::Realme::Integrator.new(application)
    message = integrator.build_message("logon")
    redirect_to(Rails.application.secrets["omniauth_realme"]["integrator"] + message)

  end
  def signin
    @realme = Realme.new(
                          customer_name: Rails.application.secrets["omniauth_realme"]["customer_name"],
                          app_name: Rails.application.secrets["omniauth_realme"]["app_name"],
                          shared_key: Rails.application.secrets["omniauth_realme"]["shared_key"])
  end

  private

  def application_params
    params.require(:realme).permit(:customer_name, :app_name)
  end
end