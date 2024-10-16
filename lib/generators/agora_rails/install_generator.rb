require 'rails/generators/base'

module AgoraRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer_file
        template "agora_rails.rb", "config/initializers/agora_rails.rb"
      end
    end
  end
end
