require 'httparty'

module AgoraRails
  class STT
    include HTTParty
    base_uri 'https://api.agora.io/v1/projects'

    def initialize
      @app_id = AgoraRails.configuration.app_id
      @customer_key = AgoraRails.configuration.customer_key
      @customer_secret = AgoraRails.configuration.customer_secret
      @auth = { username: @customer_key, password: @customer_secret }
    end

    def start_task(channel_name, uid, config)
      response = self.class.post("/#{@app_id}/rtsc/speech-to-text/tasks",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          channel_name: channel_name,
          uid: uid.to_s,
          config: config
        }.to_json
      )
      handle_response(response)
    end

    def stop_task(task_id)
      response = self.class.delete("/#{@app_id}/rtsc/speech-to-text/tasks/#{task_id}",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' }
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
