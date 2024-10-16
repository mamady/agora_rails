require 'spec_helper'
require 'json'

RSpec.describe AgoraRails::CloudRecording do
  let(:channel_name) { 'test_channel' }
  let(:uid) { '1234' }
  let(:app_id) { 'fake_app_id' }
  let(:customer_key) { 'fake_customer_key' }
  let(:customer_secret) { 'fake_customer_secret' }
  let(:resource_id) { 'fake_resource_id' }
  let(:sid) { 'fake_sid' }

  before do
    allow(AgoraRails.configuration).to receive_messages(
      app_id: app_id,
      customer_key: customer_key,
      customer_secret: customer_secret
    )
  end

  describe '#start' do
    let(:acquire_response) { { 'resourceId' => resource_id } }
    let(:start_response) { { 'resourceId' => resource_id, 'sid' => sid } }

    before do
      allow(described_class).to receive(:post).and_return(
        double(success?: true, body: acquire_response.to_json, parsed_response: acquire_response),
        double(success?: true, body: start_response.to_json, parsed_response: start_response)
      )
    end

    it 'starts a cloud recording' do
      result = described_class.new.start(channel_name, uid, {})
      
      expect(result).to eq(start_response)
      expect(described_class).to have_received(:post).twice do |url, options|
        expect(options[:basic_auth]).to eq({ username: customer_key, password: customer_secret })
        expect(options[:headers]).to include('Content-Type' => 'application/json')
        if url.include?('acquire')
          expect(JSON.parse(options[:body])).to include(
            'cname' => channel_name,
            'uid' => uid.to_s,
            'clientRequest' => { 'resourceExpiredHour' => 24 }
          )
        elsif url.include?('start')
          expect(JSON.parse(options[:body])).to include(
            'cname' => channel_name,
            'uid' => uid.to_s,
            'clientRequest' => {}
          )
        end
      end
    end

    context 'when the API returns an error' do
      before do
        allow(described_class).to receive(:post).and_return(
          double(success?: false, code: 400, body: { error: 'Bad Request' }.to_json)
        )
      end

      it 'raises an error' do
        expect { described_class.new.start(channel_name, uid, {}) }.to raise_error(AgoraRails::Error, /API request failed: 400 - {"error":"Bad Request"}/)
      end
    end
  end

  describe '#stop' do
    let(:stop_response) { { 'resourceId' => resource_id, 'sid' => sid } }

    before do
      allow(described_class).to receive(:post).and_return(
        double(success?: true, body: stop_response.to_json, parsed_response: stop_response)
      )
    end

    it 'stops a cloud recording' do
      result = described_class.new.stop(channel_name, uid, resource_id, sid)
      
      expect(result).to eq(stop_response)
      expect(described_class).to have_received(:post) do |url, options|
        expect(url).to include("/#{app_id}/cloud_recording/resourceid/#{resource_id}/sid/#{sid}/mode/mix/stop")
        expect(options[:basic_auth]).to eq({ username: customer_key, password: customer_secret })
        expect(options[:headers]).to include('Content-Type' => 'application/json')
        expect(JSON.parse(options[:body])).to include(
          'cname' => channel_name,
          'uid' => uid.to_s,
          'clientRequest' => {}
        )
      end
    end

    context 'when the API returns an error' do
      before do
        allow(described_class).to receive(:post).and_return(
          double(success?: false, code: 404, body: { error: 'Not Found' }.to_json)
        )
      end

      it 'raises an error' do
        expect { described_class.new.stop(channel_name, uid, resource_id, sid) }.to raise_error(AgoraRails::Error, /API request failed: 404 - {"error":"Not Found"}/)
      end
    end
  end
end
