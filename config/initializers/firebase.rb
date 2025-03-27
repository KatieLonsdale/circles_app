# Initialize Firebase Cloud Messaging client
if Rails.env.production?
  # In production, write the credentials content from env var to a temp file
  require 'tempfile'
  credentials_content = ENV['GOOGLE_APPLICATION_CREDENTIALS_PATH']
  credentials_file = Tempfile.new(['firebase_credentials', '.json'])
  credentials_file.write(credentials_content)
  credentials_file.close
  
  # Initialize FCM client with the temp file path
  FCM_CLIENT = FCM.new(
    credentials_file.path,
    ENV['FIREBASE_PROJECT_ID']
  )
else
  # In non-production environments, use the existing approach
  FCM_CLIENT = FCM.new(
    Figaro.env.GOOGLE_APPLICATION_CREDENTIALS_PATH,
    Figaro.env.FIREBASE_PROJECT_ID
  )
end 