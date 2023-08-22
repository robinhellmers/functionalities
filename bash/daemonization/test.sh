#!/usr/bin/env bash

########################
### Library sourcing ###
########################

library_sourcing()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    local -r THIS_SCRIPT="$(find_script 'this')"
    local -r THIS_SCRIPT_PATH="$(dirname "$THIS_SCRIPT")"

    echo "THIS_SCRIPT: $THIS_SCRIPT"
    echo "THIS_SCRIPT_PATH: $THIS_SCRIPT_PATH"
    echo
    # Store $THIS_SCRIPT_PATH as unique or local variables
    # E.g. local -r LIB_PATH="$THIS_SCRIPT_PATH/lib"
    local -r LIB_PATH="$THIS_SCRIPT_PATH/lib"
    ### Source libraries ###
    source "$LIB_PATH/handle_args.bash"
    source "$THIS_SCRIPT_PATH/main.sh"
}

# Only store output in multi-file unique readonly global variables or
# local variables to avoid variable values being overwritten in e.g.
# sourced library files.
# Recommended to always call the function when to use it
find_script()
{
    local to_find
    to_find="$1"

    local this_script_path this_script script_called_from_path
    local bash_source="${BASH_SOURCE[0]}"
    while [ -L "$bash_source" ]; do # resolve $bash_source until the file is no longer a symlink
        this_script_path=$( cd -P "$( dirname "$bash_source" )" >/dev/null 2>&1 && pwd )
        bash_source=$(readlink "$bash_source")
        # If $bash_source was a relative symlink, we need to resolve it relative
        # to the path where the symlink file was located
        [[ $bash_source != /* ]] && bash_source=$this_script_path/$bash_source 
    done
    this_script_path=$( cd -P "$( dirname "$bash_source" )" >/dev/null 2>&1 && pwd )
    this_script="$this_script_path/$(basename "$bash_source")"
    script_called_from_path="$(pwd)"

    case "$to_find" in
    'this')
        echo "$this_script"
        ;;
    'source')
        echo "$script_called_from_path"
        ;;
    *)
        echo -e "Incorrect find_script() input: '$to_find'\nExiting."
        exit 1
        ;;
    esac
}

library_sourcing

############
### MAIN ###
############
main()
{
    handle_args "$@"

    init

    handle_daemonization "$@"

    # Rest of script
    num_hello=10
    interval_hello_s=10
    echo "Going to say Hello $num_hello times with $interval_hello_s seconds \
interval."
    for (( i=0; i < num_hello; i++ ))
    do
        echo "Hello $i"
        sleep $interval_hello_s
    done
}

handle_args()
{
    _handle_args "$@"
}

init()
{
    # Daemonization files
    process_file_path="$HOME/.daemon"
    process_file_prefix="process_id"
    # log_file_stdout="$(dirname $(find_script 'this'))/log_output"
}

handle_daemonization()
{
    # Check if to run in background
    if [[ "$daemon_arg" == 'true' ]]
    then
        daemon_script="$(find_script 'this')"
        echo daemon_script: $daemon_script
        daemonize_script "$@"
        exit 0
    elif [[ "$kill_daemon_arg" == 'true' ]]
    then
        kill_daemonized_script "$kill_daemon_arg_value"
        exit 0
    fi
}

main "$@"
