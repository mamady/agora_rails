module AgoraRails
  class Configuration
    attr_accessor :app_id, :app_certificate, :customer_key, :customer_secret

    def initialize
      @app_id = nil
      @app_certificate = nil
      @customer_key = nil
      @customer_secret = nil
    end
  end
end
