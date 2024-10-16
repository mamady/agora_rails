# AgoraRails

AgoraRails is a Ruby gem that provides an interface for Agora.io APIs, specifically designed for Ruby on Rails applications. It offers functionality for generating dynamic tokens, managing cloud recording, and enabling Speech-to-Text (STT) features.

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
end
```

## Usage

### Token Generation

Generate a token for a specific channel and user:

```ruby
channel_name = 'my_channel'
uid = '1234'
role = AgoraRails::Roles::PUBLISHER
expire_time_in_seconds = 3600 # 1 hour
token = AgoraRails::TokenGenerator.generate(channel_name, uid, role, expire_time_in_seconds)
```

### Cloud Recording

Start cloud recording for a channel:

```ruby
channel_name = 'my_channel'
uid = '1234'
recording = AgoraRails::CloudRecording.start(channel_name, uid)
```

Stop cloud recording for a channel:

```ruby
resource_id = 'resource_id_from_start_recording'
sid = 'sid_from_start_recording'
AgoraRails::CloudRecording.stop(channel_name, uid, resource_id, sid)
```

### Speech-to-Text (STT)

Start STT for a channel:

```ruby
channel_name = 'my_channel'
uid = '1234'
stt_config = { / your STT configuration / }
stt = AgoraRails::STT.start(channel_name, uid, stt_config)
```

Stop STT for a channel:

```ruby
task_id = 'task_id_from_start_stt'
AgoraRails::STT.stop(task_id)
```

## Development

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

