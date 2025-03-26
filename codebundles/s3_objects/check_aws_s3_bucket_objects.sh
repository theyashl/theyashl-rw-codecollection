#!/bin/bash
auth() {
    # if required AWS_ cli vars are not set, error and exit 1
    if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY  || -z $AWS_ENDPOINT ]]; then
        echo "AWS credentials not set. Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables."
        exit 1
    fi
}
auth

# Variables
# THRESHOLD=85

# Fetch a list of bucket names
bucket_names=$(aws --endpoint "$AWS_ENDPOINT" s3api list-buckets --query "Buckets[].Name" --output text)

# Iterate over the bucket names
for bucket_name in $bucket_names; do
    # Check AWS S3 Bucket Objects Count
    count=$(aws --endpoint "$AWS_ENDPOINT" s3 ls s3://$bucket_name --recursive | wc -l)
    echo "$count"
done

