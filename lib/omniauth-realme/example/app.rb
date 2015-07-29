$:.push File.dirname(__FILE__) + '/../lib'

require 'omniauth-realme'
require 'pry'
require 'sinatra'
require "sinatra/reloader"
require 'yaml'

# configure sinatra
set :run, true
set :raise_errors, true

#########################################
# CONFIGURATION OF THE TEST APPLICATION #
#########################################

# Create test application (cust name, app name and key)
application = OmniAuth::Realme::Application.new("CelebrantsOnline","test","7feef0d575365443759eb860cc6eed48")

# The location of your application
integrator_loc = 'https://www.cloudidentityintegrator.datacom.co.nz/service/Initiator?'

#############################################
# END CONFIGURATION OF THE TEST APPLICATION #
#############################################

# client-side flow
get '/client-side' do
  content_type 'text/html'

  <<-END
    <html>
      <head>
      </head>
      <body>
        <form action='' method='POST'>
          <h3>Integrator test library</h3>
          Your application: #{ application.customer_name} - #{ application.app_name }
          <br/>
          Pick your usecase
          <select name='use_case'>
            <option selected>Logon</option>
            <option>Assert</option>
          </select>
          <br/>
          <input type='submit' name='submit' value='Test your intergrator library!'/>
        </form>
      </body>
    </html>
  END
end

post '/client-side' do
  # Actual code for constructing the message and sending to RealMe
  integrator = OmniAuth::Realme::Integrator.new(application)
  message = integrator.build_message(params[:use_case])
  redirect(integrator_loc + message)
end

# Responding to the request
get '/auth/:provider/callback' do
  # Recreate test application (cust name, app name and key)
  application = OmniAuth::Realme::Application.new("CelebrantsOnline","test","7feef0d575365443759eb860cc6eed48")

  # Build the integrator object
  integrator = OmniAuth::Realme::Integrator.new(application)

  binding.pry
  # Process the response
  response = integrator.process_response(params[:I2response])

  response.to_s
end
