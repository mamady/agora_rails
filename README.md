# AgoraRails

AgoraRails is a Ruby gem that provides an interface for Agora.io APIs, specifically designed for Ruby on Rails. It offers functionality for generating dynamic tokens and managing cloud recording.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'agora_rails'
```

And then execute:
```
$ bundle install
```

## Configuration

Create an initializer file (e.g., `config/initializers/agora_rails.rb`) and add your Agora.io credentials:

```ruby
AgoraRails.configure do |config|
  config.app_id = 'your_app_id'
  config.app_certificate = 'your_app_certificate'
  config.customer_id = 'your_customer_id'
  config.customer_secret = 'your_customer_secret'

  config.bucket = 'your_bucket'
  config.access_key = 'your_access_key'
  config.secret_key = 'your_secret_key'
  config.file_prefix = 'your_file_prefix'
end
```

The `file_prefix` is optional and is used to store the recording files in a specific folder in your bucket. For example, if you set the file_prefix to `["agora", "calls", "v3"]`, the recording files will be stored in a folder `agora/calls/v3` in your bucket.


## Usage

### Token Generation

The token generator is taken from the [Agora Tools repo](https://github.com/AgoraIO/Tools) and uses DynamicKey2.
DynamicKey2 requires `uid` to be an integer (i.e. not a string).

Generate a token for a specific channel and user:

```ruby
my_channel_name = 'my_channel'
my_uid = 1234

recorder = AgoraRails::CloudRecording.new
token = recorder.generate_token(channel_name: my_channel_name, uid: my_uid)
```
You can validate the token at https://api-agora.solutions/


### Cloud Recording

Start cloud recording for a channel:

```ruby
recorder = AgoraRails::CloudRecording.new
sid = recorder.start(channel_name: "my_channel_name", uid: 1234)
```

Using the above method assumes that you dont plan to `query` the recording, or `stop` the recording. It will "acquire" a resource and start the recording by itself.
If you plan to `query` the recording, or `stop` the recording, you will need to use the `resource_id` that is returned from the `acquire_resource` method, as shown below.

```ruby
recorder = AgoraRails::CloudRecording.new
resource_id = recorder.acquire_resource(channel_name: "my_channel", uid: 1234)
sid = recorder.start(channel_name: "my_channel", uid: 1234, resource_id: resource_id)
```


Stop cloud recording for a channel:

If you have the CloudRecording object, you can use it to stop the recording:

```ruby
recorder.stop
```

If you don't have the CloudRecording object, you can use the following method to stop the recording:

```ruby
recorder = AgoraRails::CloudRecording.new
recorder.stop(channel_name: "my_channel", resource_id: "321cba", sid: "abc123", uid: 1234, mode: "mix")
```


## Development

Contributions are welcome! Please open an issue or submit a pull request.

#### Speech-to-Text (STT)

STT support is currently being worked on.
