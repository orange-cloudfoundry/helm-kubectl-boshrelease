#!/bin/bash
set -e
bosh create-release --final

git status
git add  releases/helm-kubectl/*
git add  .final_builds/*
flag=0
while [ ${flag} = 0 ] ; do
  echo "Please set version for git release"; read version
  if [ "${version}" != "" ] ; then
    flag=1
  fi
done

git commit -m"create release $version"
git push
echo "Ensure S3 bucket are publicly available !"
# see https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html
aws s3api set-bucket-policy-status --bucket orange-helm-kubectl-boshrelease --policy file://aws-s3-bucket-policy.json

echo "Create a github release"
hub release create -m "$version" -t master $version
