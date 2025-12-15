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
Library             Collections

Suite Setup         Suite Initialization


*** Tasks ***
${TASK_TITLE}
    [Documentation]    Runs a user provided bash command and adds the output to the report.
    [Tags]    bash    cli    generic
    
    ${secret_kwargs}=    Create Dictionary

    FOR    ${key}    ${secret}    IN    &{secret_objs}
        Set To Dictionary    ${secret_kwargs}    secret_file__${key}=${secret}
    END
    
    ${decode_op}=    RW.CLI.Run Cli
    ...    cmd=echo '${GEN_CMD}' | base64 -d

    ${command}=    Catenate    SEPARATOR=\n
    ...    ${INTERPRETER} << 'EOF'
    ...    ${decode_op.stdout}
    ...    EOF
    
    ${rsp}=    RW.CLI.Run Cli
    ...    cmd=${command}
    ...    env=${raw_env_vars}
    ...    &{secret_kwargs}
    
    ${history}=    RW.CLI.Pop Shell History
    RW.Core.Add Pre To Report    Command stdout: ${rsp.stdout}
    RW.Core.Add Pre To Report    Command stderr: ${rsp.stderr}
    RW.Core.Add Pre To Report    Commands Used: ${history}


*** Keywords ***
Suite Initialization
    ${INTERPRETER}=    RW.Core.Import User Variable    INTERPRETER
    ...    type=string
    ...    description="Shell: bash or python"
    ...    default=bash
    ${GEN_CMD}=    RW.Core.Import User Variable    GEN_CMD
    ...    type=string
    ...    description=base64 encoded command to run
    ...    pattern=\w*
    ...    example="ZWNobyAnSGVsbG8gV29ybGQn"
    ${TASK_TITLE}=    RW.Core.Import User Variable    TASK_TITLE
    ...    type=string
    ...    description=The name of the task to run. This is useful for helping find this generic task with RunWhen Digital Assistants. 
    ...    pattern=\w*
    ...    example="Run a bash command"

    # env vars management
    ${env_vars_json}=    RW.Core.Import User Variable    CONFIG_ENV_MAP
    ...    type=string
    ...    description="JSON string of environment variables to values"
    ...    example="{"env_name": "env_value"}"
    ${raw_env_vars}=    Evaluate    json.loads('${env_vars_json}' if '${env_vars_json}' not in ['null', '', 'None'] else '{}')    modules=json
    ${OS_PATH}=    Get Environment Variable    PATH
    Run Keyword If    'PATH' in ${raw_env_vars}
    ...    Set To Dictionary
    ...    ${raw_env_vars}
    ...    PATH=${raw_env_vars['PATH']}:${OS_PATH}
    Run Keyword If    'PATH' not in ${raw_env_vars}
    ...    Set To Dictionary
    ...    ${raw_env_vars}
    ...    PATH=${OS_PATH}
    
    # secrets management
    ${secrets_json}=    RW.Core.Import User Variable    SECRET_ENV_MAP
    ...    type=string
    ...    description="JSON string of environment variables to secrets"
    ...    example="{"env_name": "secret_name"}"
    ${raw_secrets}=     Evaluate    json.loads('${secrets_json}' if '${secrets_json}' not in ['null', '', 'None'] else '{}')    modules=json

    ${secret_objs}=    Create Dictionary
    FOR    ${env_name}    IN    @{raw_secrets}
        ${secret_obj}=    RW.Core.Import Secret    ${env_name}
        Set To Dictionary    ${secret_objs}    ${env_name}    ${secret_obj}
    END
    
    Set Suite Variable    ${TASK_TITLE}    ${TASK_TITLE}
    Set Suite Variable    ${INTERPRETER}    ${INTERPRETER}
    Set Suite Variable    ${GEN_CMD}    ${GEN_CMD}
    Set Suite Variable    ${raw_env_vars}    ${raw_env_vars}
    Set Suite Variable    ${secret_objs}    ${secret_objs}
