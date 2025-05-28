require 'tempfile'

$firebase_credentials_file = nil

# In production, write the credentials content from env var to a temp file
def create_temp_credentials_file
  credentials_content = ENV['GOOGLE_APPLICATION_CREDENTIALS_PATH']
  credentials_file = Tempfile.new(['firebase_credentials', '.json'])
  credentials_file.write(credentials_content)
  credentials_file.rewind
  $firebase_credentials_file = credentials_file
  credentials_file.path
end

# Initialize Firebase Cloud Messaging client
if Rails.env.production?
  # Initialize FCM client with the temp file path
  fcm_credentials_path = create_temp_credentials_file
  FCM_CLIENT = FCM.new(
    fcm_credentials_path,
    ENV['FIREBASE_PROJECT_ID']
  )

  # Ensure file is cleaned up at app shutdown
  at_exit do
    $firebase_credentials_file.close
    $firebase_credentials_file.unlink
  end
else
  # In non-production environments, use the existing approach
  FCM_CLIENT = FCM.new(
    Figaro.env.GOOGLE_APPLICATION_CREDENTIALS_PATH,
    Figaro.env.FIREBASE_PROJECT_ID
  )
end