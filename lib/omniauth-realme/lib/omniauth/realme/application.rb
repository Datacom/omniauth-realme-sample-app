require 'openssl'

module OmniAuth
  module Realme
    class Application
      
      attr_accessor :customer_name
      attr_accessor :app_name
      attr_accessor :key
      attr_accessor :auth_key
      attr_accessor :enc_key

      def initialize customer, app, key
        @customer_name = customer
        @app_name = app
        @key = key

        generate_keys([@key].pack("H*"))
      end

      private

      # Generates and assigns the encryption key and the auth key.
      # The encryption key will be used later for symmetric cryptography.
      # The auth key will be used for signing.
      def generate_keys key
        # Might not produce exactly the same hash as the php version due to different return types
        keys = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, [(Digest::SHA2.new(256) << key).to_s].pack('H*'))

        @auth_key = keys[0..15]
        @enc_key = keys[16..32]
      end

    end
  end
end
