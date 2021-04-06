#!/bin/bash
bosh create-release --final

git status

echo "Ensure S3 bucket are publicly available !"
# see https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html