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
      @resource_id = nil
      @uid = "#{rand(2_000_000_000..3_000_000_000)}"
    end

    def acquire_resource(channel_name, uid = nil)
      @uid = uid if uid
      response = self.class.post("/#{@app_id}/cloud_recording/acquire",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: @uid.to_s,
          clientRequest: { resourceExpiredHour: 24 }
        }.to_json
      )
      @resource_id = handle_response(response)['resourceId']
    end

    def start(channel_name, mode = 'mix', uid = nil, recording_config = nil)
      @uid = uid if uid
      acquire_resource(channel_name)
      recording_config ||= default_recording_config(channel_name, uid)
      
      response = self.class.post("/#{@app_id}/cloud_recording/resourceid/#{@resource_id}/mode/#{mode}/start",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: @uid.to_s,
          clientRequest: recording_config
        }.to_json
      )
      sid = handle_response(response)['sid']
    end

    def stop(channel_name, uid = nil, sid, mode = 'mix')
      @uid = uid if uid
      acquire_resource(channel_name) if @resource_id.nil?

      response = self.class.post("/#{@app_id}/cloud_recording/resourceid/#{@resource_id}/sid/#{sid}/mode/#{mode}/stop",
        basic_auth: @auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: @uid.to_s,
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

    def default_recording_config(channel_name, uid)
      {
        cname: channel_name,
        uid: uid,
        clientRequest: {
          recordingConfig: {
            maxIdleTime: 30,
            streamTypes: 0, # 0: audio only, 1: audio and video, 2: video only
            channelType: 0, # 0: communication (audio call / video call), 1: live-broadcast (video live streaming)
          },
          recordingFileConfig: {
            avFileType: [
              "hls",
              "mp4"
            ],
          },
          storageConfig: {
            vendor: 1, # 1: AWS, 2: Azure, 3: GCP, 4: Aliyun, 5: Tencent, 6: Qiniu, 7: AWS_S3, 8: Azure_Blob, 9: GCP_Storage, 10: Aliyun_OSS, 11: Tencent_COS, 12: Qiniu_Kodo
            region: 1, # 1: us-east-1, 2: us-east-2, 3: us-west-1, 4: us-west-2, 5: eu-west-1, 6: eu-west-2, 7: eu-west-3, 8: eu-central-1, 9: ap-southeast-1, 10: ap-southeast-2, 11: ap-northeast-1, 12: ap-northeast-2, 13: ap-northeast-3, 14: ap-south-1, 15: sa-east-1
            bucket: AgoraRails.configuration.bucket,
            accessKey: AgoraRails.configuration.access_key,
            secretKey: AgoraRails.configuration.secret_key,
            fileNamePrefix: ["agora"],
          },
        },
      }
    end
  end
end
