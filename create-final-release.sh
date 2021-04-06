#!/bin/bash
set -e
bosh create-release --final

git status
git add  releases/helm-kubectl/*
git add  .final_builds/*


echo "Ensure S3 bucket are publicly available !"
# see https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html
echo "Create a github release"
