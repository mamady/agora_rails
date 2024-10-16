AgoraRails.configure do |config|
  config.app_id = "YOUR_APP_ID"
  config.app_certificate = "YOUR_APP_CERTIFICATE"
  config.customer_key = "YOUR_CUSTOMER_KEY"
  config.customer_secret = "YOUR_CUSTOMER_SECRET"

  # the following are optional
  config.bucket = "YOUR_BUCKET"
  config.access_key = "YOUR_ACCESS_KEY"
  config.secret_key = "YOUR_SECRET_KEY"
end
