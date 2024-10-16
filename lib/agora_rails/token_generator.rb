require 'openssl'
require 'base64'
require 'securerandom'



module AgoraRails
  class TokenGenerator

    def self.generate(channel_name, uid, role, privilege_expired_ts)
      app_id = AgoraRails.configuration.app_id
      app_certificate = AgoraRails.configuration.app_certificate

      raise AgoraRails::Error, "App ID and certificate must be configured" if app_id.nil? || app_certificate.nil?

      token = AccessToken.new(app_id, app_certificate, channel_name, uid)
      token.add_privilege(role, privilege_expired_ts)
      token.build
    end

    class AccessToken
      VERSION = "006"

      attr_accessor :app_id, :app_certificate, :channel_name, :uid, :ts, :salt, :privileges

      def initialize(app_id, app_certificate, channel_name, uid)
        @app_id = app_id
        @app_certificate = app_certificate
        @channel_name = channel_name
        @uid = uid
        @ts = (Time.now.to_f * 1000).to_i
        @salt = SecureRandom.random_number(99999999)
        @privileges = {}
      end

      def add_privilege(privilege, expire_ts)
        @privileges[privilege] = expire_ts
      end

      def build
        signing = build_signing
        signature = hmac_sign(signing)
        compact_signature = signature[0...32]

        VERSION + @app_id + encode_hex(@salt) + encode_hex(@ts) + encode_hex(compact_signature)
      end

      private

      def build_signing
        signing = @app_id + @channel_name + @uid + encode_privileges
        signing.force_encoding('ASCII-8BIT')
      end

      def encode_privileges
        buffer = ""
        @privileges.each do |key, value|
          buffer << [key, value].pack('S>I>')
        end
        buffer
      end

      def hmac_sign(message)
        OpenSSL::HMAC.digest('sha256', @app_certificate, message)
      end

      def encode_hex(value)
        value.to_s(16).rjust(8, '0')
      end
    end
  end
end