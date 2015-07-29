require 'openssl'
require 'active_support/core_ext/hash' # XML parsing

module OmniAuth
  module Realme
    class Integrator

      CBC_BLOCK_SIZE = 16

      attr_accessor :application

      def initialize application
        @application = application
      end
      
      # Constructs the message to send to RealMe and returns it as a string
      def build_message use_case
        # Generate timestamp and nonce
        time_stamp = Time.now.strftime("%Y-%m-%d\T%H:%M:%S\Z")
        nonce = Random.new.bytes(8).unpack('H*')[0]
        
        # Builds the message
        message = "<UseCase>#{ use_case }</UseCase><Nonce>#{ nonce }</Nonce><TimeStamp>#{ time_stamp }</TimeStamp>"
         
        # Encrypt and sign
        request = encrypt_and_sign(message, use_case)

        # Encode
        request = Rack::Utils.escape(Base64.strict_encode64(request))

        "custname=#{ @application.customer_name }&appname=#{ @application.app_name }&I2request=#{ request }"
      end

      # Decrypts and processes the response into manageable components and checks for errors
      def process_response response
        # Decode the message
        response = Base64.decode64(response)

        # Separate response into components
        init_vector = response[0..15]
        mac = response[16..47]
        cipher = response[48..-1]

        # Regenerate the MAC and ensure it is the one we are looking for
        generated_mac = sign(init_vector + cipher)

        if generated_mac != mac
          response = {
            internal_error: :bad_signing,
            generated_mac: Base64.strict_encode64(generated_mac),
            passed_mac: Base64.strict_encode64(mac)
          }
        else
          # Decrypt and unpack the response string
          response = decrypt_and_unpack cipher, init_vector

          # Further process the response into a workable hash
          response = realme_response_to_hash(response)

          # Check not-before / not-after dates
          if check_within_dates(response)
            # Everything is OK, return the response (remove the date values first, these should remain internal)
            response['IIMessageNotBefore'] = nil
            response['IIMessageNotAfter'] = nil
          else
            # We are not within the given dates, return an error
            response = {
              internal_error: :bad_dates,
              start_date: response['IIMessageNotBefore'],
              end_date: response['IIMessageNotAfter'],
              current_date: Time.now.utc.strftime("%Y-%m-%d\T%H:%M:%S\Z")
            }
          end

          response
        end
      end

      private

      # The PHP version of this method uses Mcrypt with Rijndael-128-CBC encryption.
      # We can use OpenSSL's AES-128-CBC encryption to do the same thing, as it is based off of the
      # Rijndael cipher.
      def encrypt_and_sign message, use_case
        # Additional auth data
        additional_auth_data = "#{ @application.customer_name }|#{ @application.app_name }|"

        # Instantiate the cipher, set the mode to encryption, and generate IV
        cipher = OpenSSL::Cipher::AES.new(128, :CBC)
        cipher.encrypt
        cipher.padding = 0
        init_vector = Random.new.bytes(16)
        cipher.iv = init_vector

        # Pad the message manually
        padding = CBC_BLOCK_SIZE - (message.length % CBC_BLOCK_SIZE)
        message += (padding.chr * padding)

        # Encrypt the message
        cipher.key = @application.enc_key
        message_encrypt = cipher.update(message) + cipher.final

        # Sign the encrypted message
        message_hmac = sign(init_vector + message_encrypt + additional_auth_data)
         
        "#{ init_vector }#{ message_hmac }#{ message_encrypt }"
      end

      # Sign an encryption with the application auth key
      def sign data
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), @application.auth_key, data)
      end

      def decrypt_and_unpack response, init_vector
        # Decrypt the string
        decipher = OpenSSL::Cipher::AES.new(128, :CBC)
        decipher.decrypt
        decipher.padding = 0
        decipher.iv = init_vector
        decipher.key = @application.enc_key

        decrypted_string = decipher.update(response) + decipher.final

        # Detect if padding was used by iterating over the last elements of the string
        padding = decrypted_string[-1].ord
        if padding && (padding < CBC_BLOCK_SIZE)
          (0..(padding-1)).each do |i|
            # If one of the final elements of the string does not match the padding element, we know that
            # padding was not used, so set it to 0.
            padding = 0 if decrypted_string[-1 - i].ord != padding
          end
        end

        # Unpack
        decrypted_string[0..(-1 - padding)]
      end

      # This method takes the XML string and creates an associative hash
      def realme_response_to_hash response
        response_array = Hash.from_xml('<root>'+response+'</root>')
        
        response_array["root"]
      end

      # Checks dates exist and that we are currently between them
      def check_within_dates response
        return true unless response['IIMessageNotBefore'] || response['IIMessageNotAfter']

        before_date = Time::strptime(response['IIMessageNotBefore'], "%Y-%m-%d\T%H:%M:%S%Z")
        after_date = Time::strptime(response['IIMessageNotAfter'], "%Y-%m-%d\T%H:%M:%S%Z")

        (Time.now.utc < after_date && Time.now.utc > before_date)
      end

    end
  end
end
