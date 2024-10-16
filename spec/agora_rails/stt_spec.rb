require 'spec_helper'

RSpec.describe AgoraRails::STT do
  let(:channel_name) { 'test_channel' }
  let(:uid) { '1234' }
  let(:stt_config) { { language: 'en-US' } }

  before do
    allow(AgoraRails::TokenGenerator).to receive(:generate).and_return('fake_token')
    allow(Net::HTTP).to receive(:start).and_return(double(code: '200', body: '{"taskId":"fake_task_id"}'))
  end

  describe '.start' do
    it 'starts an STT session' do
      result = described_class.start(channel_name, uid, stt_config)
      expect(result).to eq({ "taskId" => "fake_task_id" })
    end
  end

  describe '.stop' do
    it 'stops an STT session' do
      task_id = 'fake_task_id'

      result = described_class.stop(task_id)
      expect(result).to eq({ "taskId" => "fake_task_id" })
    end
  end
end
