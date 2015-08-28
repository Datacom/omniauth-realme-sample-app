class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def realme
    auth = request.env["omniauth.auth"]

    # Check for error cases
    if auth.info.message_type == 'Error'
      case auth.info.status_code
      when 'urn:oasis:names:tc:SAML:2.0:status:AuthnFailed'
        flash[:error] = 'You have chosen to leave the RealMe login screen without completing the login process.'
      when 'urn:nzl:govt:ict:stds:authn:deployment:RealMe:SAML:2.0:status:Timeout'
        flash[:error] = 'Your RealMe session has timed out – please try again.'
      when 'urn:oasis:names:tc:SAML:2.0:status:UnknownPrincipal'
        flash[:error] = 'You are unable to use RealMe to verify your identity if you do not have a RealMe account. Visit the RealMe home page for more information and to create an account.'
      when 'urn:nzl:govt:ict:stds:authn:deployment:RealMe:SAML:2.0:status:InternalError'
        flash[:error] = 'RealMe was unable to process your request due to a RealMe internal error. Please try again. If the problem persists, please contact RealMe Help Desk on 0800 664 774'
      when 'urn:oasis:names:tc:SAML:2.0:status:NoAvailableIDP'
        flash[:error] = 'RealMe reported that the TXT service or the igovt token service is not available. You may try again later. If the problem persists, please contact the RealMe Help Desk: From New Zealand: 0800 664 774 (toll free) From overseas: +64 9 357 4468 (overseas call charges apply).'
      when 'urn:oasis:names:tc:SAML:2.0:status:RequestDenied'
        flash[:error] = 'RealMe reported a serious application error with the message Request Denied. Please try again later. If the problem persists, please contact RealMe Help Desk on 0800 664 774.'
      when 'urn:oasis:names:tc:SAML:2.0:status:RequestUnsupported'
        flash[:error] = 'RealMe reported a serious application error with the message Request Unsupported. Please try again later. If the problem persists, please contact RealMe Help Desk on 0800 664 774.'
      when 'urn:oasis:names:tc:SAML:2.0:status:NoAuthnContext'
        flash[:error] = 'RealMe reported a serious application error with the message No Authentication Context. Please try again later. If the problem persists, please contact RealMe Help Desk on 0800 664 774.'
      when 'urn:oasis:names:tc:SAML:2.0:status:NoPassive'
        flash[:error] = 'RealMe reported a serious application error with the message No Passive. Please try again later. If the problem persists, please contact RealMe Help Desk on 0800 664 774.'
      else
        flash[:error] = 'RealMe reported a serious application error. Please try again later. If the problem persists, please contact RealMe Help Desk on 0800 664 774.'
      end

      return redirect_to root_path
    end

    @user = User.from_omniauth(auth)

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Realme") if is_navigational_format?
    else
      # If for some reason the user cannot be saved
      raise 'RealMe user was not found or created'
    end
  end
end