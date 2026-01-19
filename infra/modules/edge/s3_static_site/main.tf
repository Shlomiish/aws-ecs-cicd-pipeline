# ------ S3 BUCKET (STATIC CLIENT ORIGIN) ------

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

}

# ------ S3 PUBLIC ACCESS HARDENING ------

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true # Prevents setting public ACLs on objects/bucket
  block_public_policy     = true # Prevents attaching public bucket policies
  ignore_public_acls      = true # Ignores any existing public ACLs
  restrict_public_buckets = true # Blocks public access even if a public policy exists
}

