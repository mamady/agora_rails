require 'httparty'

module AgoraRails
  class CloudRecording
    include HTTParty
    base_uri 'https://api.agora.io/v1/apps'

    def initialize
      @app_id = AgoraRails.configuration.app_id
      @customer_key = AgoraRails.configuration.customer_key
      @customer_secret = AgoraRails.configuration.customer_secret
      @auth = { username: @customer_key, password: @customer_secret }
    end

    def acquire_resource(channel_name, uid)
      response = self.class.post("/#{@app_id}/cloud_recording/acquire",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: uid.to_s,
          clientRequest: { resourceExpiredHour: 24 }
        }.to_json
      )
      handle_response(response)
    end

    def start_recording(resource_id, channel_name, uid, recording_config)
      response = self.class.post("/#{@app_id}/cloud_recording/resourceid/#{resource_id}/mode/mix/start",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: uid.to_s,
          clientRequest: recording_config
        }.to_json
      )
      handle_response(response)
    end

    def stop_recording(resource_id, sid, channel_name, uid)
      response = self.class.post("/#{@app_id}/cloud_recording/resourceid/#{resource_id}/sid/#{sid}/mode/mix/stop",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: uid.to_s,
          clientRequest: {}
        }.to_json
      )
      handle_response(response)
    end

    private

    def handle_response(response)
      if response.success?
        JSON.parse(response.body)
      else
        raise AgoraRails::Error, "API request failed: #{response.code} - #{response.body}"
      end
    end
  end
end
