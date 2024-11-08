require 'dynamic_key2'
require 'httparty'

module AgoraRails
  class CloudRecording
    include HTTParty
    base_uri 'https://api.agora.io/v1/apps'
    
    debug_output $stdout # uncomment this for debugging i.e. output to stdout

    attr_accessor :app_id, :app_certificate, :customer_key, :customer_secret, :auth, :resource_id, :uid, :bucket, :access_key, :secret_key, :sid, :channel_name, :mode, :file_prefix

    def initialize
      self.app_id = AgoraRails.configuration.app_id
      self.app_certificate = AgoraRails.configuration.app_certificate
      self.customer_key = AgoraRails.configuration.customer_key
      self.customer_secret = AgoraRails.configuration.customer_secret
      self.auth = { username: customer_key, password: customer_secret }
      self.uid = "#{rand(2_000_000_000..3_000_000_000)}"
      self.mode = 'mix'
      self.file_prefix = AgoraRails.configuration.file_prefix || ''
    end

    def acquire_resource(opts)
      channel_name, uid = opts.values_at(:channel_name, :uid)
      raise "Invalid Channel Name" if channel_name.nil?
      self.channel_name = channel_name
      self.uid = uid if uid
      response = self.class.post("/#{app_id}/cloud_recording/acquire",
        basic_auth: auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: channel_name,
          uid: self.uid.to_s,
          clientRequest: { resourceExpiredHour: 24 }
        }.to_json
      )
      handle_response(response)['resourceId']
    end

    def start(opts = {})
      channel_name, uid, resource_id, mode, recording_config = opts.values_at(:channel_name, :uid, :resource_id, :mode, :recording_config)
      raise "Invalid Channel Name" if self.channel_name.nil? && channel_name.nil?
      self.channel_name = channel_name if channel_name
      self.uid = uid if uid
      self.mode = mode if mode
      self.resource_id = resource_id || acquire_resource(channel_name: channel_name, uid: self.uid)
      recording_config ||= default_recording_config(channel_name, self.uid)

      response = self.class.post("/#{app_id}/cloud_recording/resourceid/#{resource_id}/mode/#{self.mode}/start",
        basic_auth: auth,
        headers: { 'Content-Type' => 'application/json' },
        body: recording_config.to_json
      )
      self.sid = handle_response(response)['sid']
    end

    def stop(opts)
      channel_name, resource_id, sid, uid, mode = opts.values_at(:channel_name, :resource_id, :sid, :uid, :mode)
      raise "Invalid Channel Name" if channel_name.nil? && self.channel_name.nil?
      raise "Invalid Resource ID" if resource_id.nil? && self.resource_id.nil?
      raise "Invalid SID" if sid.nil? && self.sid.nil?
      self.channel_name = channel_name if channel_name
      self.resource_id = resource_id if resource_id
      self.sid = sid if sid
      self.uid = uid if uid
      self.mode = mode if mode

      response = self.class.post("/#{app_id}/cloud_recording/resourceid/#{self.resource_id}/sid/#{self.sid}/mode/#{self.mode}/stop",
        basic_auth: auth,
        headers: { 'Content-Type' => 'application/json' },
        body: {
          cname: self.channel_name,
          uid: self.uid.to_s,
          clientRequest: {}
        }.to_json
      )
      handle_response(response)
    end

    def query(opts)
      resource_id, sid, mode = opts.values_at(:resource_id, :sid, :mode)
      raise "Invalid Resource ID" if resource_id.nil? && self.resource_id.nil?
      raise "Invalid SID" if sid.nil? && self.sid.nil?
      self.resource_id = resource_id if resource_id
      self.sid = sid if sid
      self.mode = mode if mode

      response = self.class.get("/#{app_id}/cloud_recording/resourceid/#{self.resource_id}/sid/#{self.sid}/mode/#{self.mode}/query",
        basic_auth: auth,
        headers: { 'Content-Type' => 'application/json' },
      )
      handle_response(response)
    end


    def generate_token(opts = {})
      channel_name, uid = opts.values_at(:channel_name, :uid)
      self.channel_name = channel_name if channel_name
      self.uid = uid if uid

      token_expiration_in_seconds = 3600 # 1 hour
      privilege_expiration_in_seconds = 3600 # 1 hour
      ::AgoraDynamicKey2::RtcTokenBuilder.build_token_with_uid(
        app_id, app_certificate, self.channel_name, self.uid,
        ::AgoraDynamicKey2::RtcTokenBuilder::ROLE_PUBLISHER, token_expiration_in_seconds, privilege_expiration_in_seconds
      )
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
        uid: uid.to_s,
        clientRequest: {
          token: generate_token,
          recordingConfig: {
            maxIdleTime: 30,
            streamTypes: 0, # 0: audio only, 1: audio and video, 2: video only
            channelType: 0, # 0: communication (audio call / video call), 1: live-broadcast (video live streaming)
          },
          storageConfig: {
            vendor: 1, # 1: AWS, 2: Azure, 3: GCP, 4: Aliyun, 5: Tencent, 6: Qiniu, 7: AWS_S3, 8: Azure_Blob, 9: GCP_Storage, 10: Aliyun_OSS, 11: Tencent_COS, 12: Qiniu_Kodo
            region: 0, # 0: us-east-1, 1: us-east-2
            bucket: AgoraRails.configuration.bucket,
            accessKey: AgoraRails.configuration.access_key,
            secretKey: AgoraRails.configuration.secret_key,
            fileNamePrefix: file_prefix.map(&:to_s), # convert to array of strings
          },
        },
      }
    end
  end
end
