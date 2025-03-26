*** Settings ***
Documentation      This taskset uses aws local deployment to check the number of objects present in given bucket
Metadata           Author        Prathamesh
Metadata           Display Name  S3 Objects List
Library            BuiltIn
Library            RW.Core
Library            RW.CLI

Suite Setup        Suite Initialization

*** Keywords ***
Suite Initialization
    ${AWS_REGION}=    RW.Core.Import User Variable    AWS_REGION
    ...    type=string
    ...    description=AWS Region
    ...    pattern=\w*
    ...    default=us-east-1
    ...    example=us-east-1
    ${AWS_ENDPOINT}=  RW.Core.Import User Variable    AWS_ENDPOINT
    ...    type=string
    ...    description=AWS Endpoint
    ...    pattern=\w*
    ...    default=http://localhost:4566
    ...    example=http://localhost:4566
    ${AWS_ACCESS_KEY_ID}=    RW.Core.Import Secret   AWS_ACCESS_KEY_ID
    ...    type=string
    ...    description=AWS Endpoint
    ...    description=AWS Access Key ID
    ...    pattern=\w*
    ${AWS_SECRET_ACCESS_KEY}=    RW.Core.Import Secret   AWS_SECRET_ACCESS_KEY
    ...    type=string
    ...    description=AWS Secret Access Key
    ...    pattern=\w*

    Set Suite Variable    ${AWS_REGION}    ${AWS_REGION}
    Set Suite Variable    ${AWS_ACCESS_KEY_ID}    ${AWS_ACCESS_KEY_ID}
    Set Suite Variable    ${AWS_SECRET_ACCESS_KEY}    ${AWS_SECRET_ACCESS_KEY}
    Set Suite Variable
    ...    &{env}
    ...    AWS_REGION=${AWS_REGION}

*** Tasks ***
Check AWS S3 Bucket Objects
    [Documentation]   This script checks and displays the objects utilization of a specified AWS S3 bucket. It uses the AWS CLI to list all objects in the bucket recursively, displaying the results in a human-readable format and providing a count of the total objects stored.
    [Tags]  Amazon Web Services    AWS S3 
    ${process}=    RW.CLI.Run Bash File    check_aws_s3_bucket_objects.sh
    ...    env=${env}
    ...    secret__AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
    ...    secret__AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    ${msg}=    MyKeywords.S3Objects.get_report_msg   int(${process.stdout})
    RW.Core.Add Pre To Report    ${msg}
