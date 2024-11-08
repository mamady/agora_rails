module AgoraRails
  class Configuration
    attr_accessor :app_id, :app_certificate, :customer_key, :customer_secret, :bucket, :access_key, :secret_key, :file_prefix

    def initialize
      @app_id = nil
      @app_certificate = nil
      @customer_key = nil
      @customer_secret = nil
      @bucket = nil
      @access_key = nil
      @secret_key = nil
      @file_prefix = nil
    end
  end
end
