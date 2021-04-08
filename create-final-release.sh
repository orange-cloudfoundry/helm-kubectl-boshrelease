#!/bin/bash
set -e
bosh create-release --final

git status
git add  releases/helm-kubectl/*
git add  .final_builds/*
version=$(ruby -r yaml -e 'index=YAML.load_file("releases/helm-kubectl/index.yml");puts index["builds"].values.flat_map{|version| version.values}.flat_map{|string| string.to_i}.max')

git commit -m"create release $version"
git tag "$version"
git push
echo "Ensure S3 bucket are publicly available !"
# see https://docs.aws.amazon.com/cli/latest/reference/s3api/put-bucket-policy.html
aws s3api set-bucket-policy-status --bucket orange-helm-kubectl-boshrelease --policy file://aws-s3-bucket-policy.json

echo "Create a github release"
{
  echo "$version"
  echo ""
  git log --graph --decorate --pretty=oneline --abbrev-commit $((version-1))..$version
} >.git/release-$version.txt
hub release create -F .git/release-$version.txt -t master $version
