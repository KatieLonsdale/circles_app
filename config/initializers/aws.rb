require 'aws-sdk-s3'

Aws.config.update({
  region: Figaro.env.AWS_REGION,
  credentials: Aws::Credentials.new(Figaro.env.AWS_ACCESS_KEY_ID, Figaro.env.AWS_SECRET_ACCESS_KEY)
})

S3_BUCKET = Figaro.env.S3_BUCKET_NAME
