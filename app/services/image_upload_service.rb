require 'aws-sdk-s3'

class ImageUploadService
  def initialize
    @s3_client = Aws::S3::Client.new
    @bucket_name = Figaro.env.S3_BUCKET_NAME
    @base_url = "https://#{@bucket_name}.s3.amazonaws.com/"
  end

  def self.upload(byte_array, folder, content_id)
    s3_client = Aws::S3::Client.new
    file_name = "#{SecureRandom.hex(10)}.jpg"
    bucket_name = Figaro.env.S3_BUCKET_NAME
    
    # Convert byte array to an image
    File.open(file_name, 'wb') do |file|
      file.write(byte_array.pack('C*'))
      file.close
    end

    begin
      # Upload the file to S3
      object_key = "#{folder}/#{file_name}"
      s3_file = s3_client.put_object(
        bucket: bucket_name, 
        key: object_key, 
        body: File.read(file_name), 
        content_type: "image/jpeg"
      )
      
      # Delete the file after a successful upload
      File.delete(file_name) if File.exist?(file_name)
      puts "File deleted locally after upload to S3."
    
    rescue Aws::S3::Errors::ServiceError => e
      puts "Failed to upload to S3: #{e.message}"
      # Handle any additional error logging or handling here
    end

    # assign image_url to content
    s3_image_url = "https://#{bucket_name}.s3.amazonaws.com/#{object_key}"
    content = Content.find(content_id)
    content.image_url = s3_image_url
    content.save
  end

  def create_presigned_url(image_url)
    object_key = image_url.gsub(@base_url, "")
    bucket = Aws::S3::Bucket.new(@bucket_name)
    presigned_url = bucket.object(object_key).presigned_url(:get, expires_in: 3600)
    return presigned_url

    rescue Aws::Errors::ServiceError => e
      puts "Couldn't create presigned URL for #{bucket.name}:#{object_key}. Here's why: #{e.message}"
    end
end

# TODO: these should not be class methods, add initialize method