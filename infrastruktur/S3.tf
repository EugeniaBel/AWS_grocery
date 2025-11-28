resource "aws_s3_bucket" "avatars" {
    bucket = "grocerymate-jennys-avatars"

    tags = {
      Name = "grocerymate-jennys-avatars"
      Environment = "Dev" # Можна додати тег Environment
    }
}

# 2. Ресурс блокування публічного доступу (для безпеки)
resource "aws_s3_bucket_public_access_block" "avatars_public_access_block" {
  bucket = aws_s3_bucket.avatars.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}