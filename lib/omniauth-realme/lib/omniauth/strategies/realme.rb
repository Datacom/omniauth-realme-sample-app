require 'omniauth'
require 'omniauth/realme/application'
require 'openssl'
require 'rack/utils'
require 'uri'

module OmniAuth
  module Strategies
    class Realme
      include OmniAuth::Strategy

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
        # Change the return URL if there is one
        queries = Rack::Utils.parse_nested_query(request.env["QUERY_STRING"])
        options[:return_url] = queries["return_url"] if queries["return_url"]
        options[:logon_type] = (queries["logon_type"] && queries["logon_type"].downcase == "assert") ? "Assert" : "Logon"

        redirect_uri = OmniAuth::Realme::CloudIdentityIntegrator.build_redirect_uri(options[:logon_type])
        redirect redirect_uri
      end

      uid { @raw_info["FLT"] || @raw_info["FIT"] } # Leave the FIT in just incase someone is using the test integrator

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
          status_message: @raw_info["StatusMessage"],
          fit:            @raw_info["FIT"]
        }
      end

      extra do
        {
          return_url:     @raw_info["ReturnURL"]
        }
      end

      # Fills out the omniauth.auth hash upon receiving a callback from the RealMe servers
      def callback_phase
        query_string = URI.decode(request.env["QUERY_STRING"][11..-1])
        @raw_info = OmniAuth::Realme::CloudIdentityIntegrator.process_callback(query_string)

        # Calculate the return URL
        @raw_info["ReturnURL"] = options[:return_url]
        super
      end
    end
  end
end