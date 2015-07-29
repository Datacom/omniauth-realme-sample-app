require 'omniauth'
require 'omniauth/realme/application'
require 'omniauth/realme/integrator'
require 'openssl'
require 'rack/utils'
require 'uri'

module OmniAuth
  module Strategies
    class Realme
      include OmniAuth::Strategy

      args [:client_name, :app_name, :shared_key]

      option :name, "realme"

      option :client_options, {
        :request_token_path => '/auth/realme',
        :authorize_path => '/auth/realme/callback'
      }

      option :return_url, nil
      option :logon_type, "Logon"

      attr_accessor :raw_info

      # Initiated when app attempts to access /auth/realme. Sends the user to the RealMe login
      def request_phase
        application = OmniAuth::Realme::Application.new(options[:client_name], options[:app_name], options[:shared_key])
        integrator_loc = "https://www.cloudidentityintegrator.datacom.co.nz/service/Initiator?"

        # Change the return URL if there is one
        queries = Rack::Utils.parse_nested_query(request.env["QUERY_STRING"])
        options[:return_url] = queries["return_url"] if queries["return_url"]
        options[:logon_type] = (queries["logon_type"] && queries["logon_type"].downcase == "assert") ? "Assert" : "Logon"

        integrator = OmniAuth::Realme::Integrator.new(application)
        message = integrator.build_message(options[:logon_type]) # Test use case
        redirect (integrator_loc + message)
      end

      uid { @raw_info["FIT"] || @raw_info["FLT"] }

      info do
        {
          first_name:     @raw_info["FirstName"],
          middle_name:    @raw_info["MiddleName"],
          last_name:      @raw_info["LastName"],
          gender:         @raw_info["Gender"],
          birth_day:      @raw_info["BirthDay"],
          birth_month:    @raw_info["BirthMonth"],
          birth_year:     @raw_info["BirthYear"],
          birth_country:  @raw_info["BirthCountry"],
          unit:           @raw_info["Unit"],
          number_street:  @raw_info["NumberStreet"],
          suburb:         @raw_info["Suburb"],
          rural_delivery: @raw_info["RuralDelivery"],
          town_city:      @raw_info["TownCity"],
          message_type:   @raw_info["MessageType"],
          status_code:    @raw_info["StatusCode"],
          status_message: @raw_info["StatusMessage"]
        }
      end

      extra do
        {
          return_url:     @raw_info["ReturnURL"]
        }
      end

      # Fills out the omniauth.auth hash upon receiving a callback from the RealMe servers
      def callback_phase
        # Parse the response into a hash
        application = OmniAuth::Realme::Application.new(options[:client_name], options[:app_name], options[:shared_key])
        integrator = OmniAuth::Realme::Integrator.new(application)
        # Get the query string response - TODO: is this the best way to manage the response string?
        response = integrator.process_response(URI.decode(request.env["QUERY_STRING"][11..-1]))

        # Check for errors
        if response[:internal_error]
          case response[:internal_error]
            when :bad_signing
              raise 'Bad signing'
            when :bad_dates
              raise 'Bad dates'
            else
              raise 'Error with RealMe authentication'
          end
        end

        # Calculate the return URL
        response["ReturnURL"] = options[:return_url]

        # Return the correctly filled omniauth.auth hash
        @raw_info = response
        super
      end

    end
  end
end