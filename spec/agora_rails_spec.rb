require 'spec_helper'

RSpec.describe AgoraRails do
  it "has a version number" do
    expect(AgoraRails::VERSION).not_to be nil
  end

  describe ".configure" do
    it "allows setting configuration options" do
      AgoraRails.configure do |config|
        config.app_id = 'test_app_id'
        config.app_certificate = 'test_app_certificate'
        config.customer_id = 'test_customer_id'
        config.customer_secret = 'test_customer_secret'
      end

      expect(AgoraRails.configuration.app_id).to eq('test_app_id')
      expect(AgoraRails.configuration.app_certificate).to eq('test_app_certificate')
      expect(AgoraRails.configuration.customer_id).to eq('test_customer_id')
      expect(AgoraRails.configuration.customer_secret).to eq('test_customer_secret')
    end
  end
end
