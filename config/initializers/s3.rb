if Rails.env == "production" 
   S3_CREDENTIALS = Rails.root.join("config/s3.yml")
 else 
   S3_CREDENTIALS = Rails.root.join("config/s3.yml")
end