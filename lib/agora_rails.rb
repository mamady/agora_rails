require_relative "agora_rails/configuration"
require_relative "agora_rails/cloud_recording"
require_relative "agora_rails/stt"

module AgoraRails
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
