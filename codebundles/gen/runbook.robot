*** Settings ***
Documentation       Gen Taskset
Metadata            Author    theyashl
Metadata            Display Name    Gen Taskset
Metadata            Supports    bash

Library             BuiltIn
Library             RW.Core
Library             RW.platform
Library             OperatingSystem
Library             RW.CLI

Suite Setup         Suite Initialization


*** Tasks ***
${TASK_TITLE}
    [Documentation]    Runs a user provided bash command and adds the output to the report.
    [Tags]    bash    cli    generic
    
    ${rsp}=    RW.CLI.Run Cli
    ...    cmd=${BASH_COMMAND}
    
    ${history}=    RW.CLI.Pop Shell History
    RW.Core.Add Pre To Report    Command stdout: ${rsp.stdout}
    RW.Core.Add Pre To Report    Command stderr: ${rsp.stderr}
    RW.Core.Add Pre To Report    Commands Used: ${history}


*** Keywords ***
Suite Initialization
    ${BASH_COMMAND}=    RW.Core.Import User Variable    BASH_COMMAND
    ...    type=string
    ...    description=The bash command to run
    ...    pattern=\w*
    ...    example="echo 'Hello World'"
    ${TASK_TITLE}=    RW.Core.Import User Variable    TASK_TITLE
    ...    type=string
    ...    description=The name of the task to run. This is useful for helping find this generic task with RunWhen Digital Assistants. 
    ...    pattern=\w*
    ...    example="Run a bash command"
    
    Set Suite Variable    ${TASK_TITLE}    ${TASK_TITLE}
    Set Suite Variable    ${BASH_COMMAND}    ${BASH_COMMAND}