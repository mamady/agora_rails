require "agora_rails/version"
require "agora_rails/configuration"
require "agora_rails/token_generator"
require "agora_rails/cloud_recording"
require "agora_rails/stt"

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
