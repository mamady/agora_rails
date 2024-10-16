require 'spec_helper'

RSpec.describe AgoraRails::TokenGenerator do
  before do
    AgoraRails.configure do |config|
      config.app_id = 'test_app_id'
      config.app_certificate = 'test_app_certificate'
    end
  end

  describe '.generate' do
    it 'generates a token' do
      channel_name = 'test_channel'
      uid = '1234'
      role = 1
      privilege_expired_ts = Time.now.to_i + 3600

      token = described_class.generate(channel_name, uid, role, privilege_expired_ts)

      expect(token).to be_a(String)
      expect(token).to start_with('006test_app_id')
    end

    it 'raises an error if app_id or app_certificate is not configured' do
      AgoraRails.configure do |config|
        config.app_id = nil
        config.app_certificate = nil
      end

      expect {
        described_class.generate('channel', 'uid', 1, Time.now.to_i)
      }.to raise_error(AgoraRails::Error, "App ID and certificate must be configured")
    end
  end
end
