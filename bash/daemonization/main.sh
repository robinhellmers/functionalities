
daemonize_script()
{
    _check_daemonize_script_variables

    echo "Daemonizing script:"
    echo "    $daemon_script"

    # Remove --daemon option from arguments to avoid infinite loop when calling
    # the script again
    for arg in "$@"
    do
        [[ "$arg" != "--daemon" ]] && local other_args+=( "$arg" )
    done

    local piping=""
    [[ -f "$log_file_stdout" ]] && piping=">$log_file_stdout 2>&1"

    # Run script as background job
    "$daemon_script" "${other_args[@]}" </dev/null "$piping" &
    local process_id=$!

    # Create file indicating daemon process id
    process_file="$process_file_path/${process_file_prefix}-${process_id}"
    echo "$process_id" > "$process_file"

    # Disown the background job
    disown

    # Continues this script instance
}

_check_daemonize_script_variables()
{
    if [[ -z "$daemon_script" ]]
    then
        echo "daemonize_script: Script not given in \$daemon_script."
        echo "Exiting."
        exit 1
    elif ! [[ -f "$daemon_script" ]]
    then
        echo "daemonize_script: \$daemon_script is not a file."
        echo "\$daemon_script: $daemon_script"
        echo "Exiting."
        exit 1
    elif ! [[ -x "$daemon_script" ]]
    then
        echo "daemonize_script: \$daemon_script is not executable."
        echo "\$daemon_script: $daemon_script"
        echo "Exiting."
        exit 1
    elif [[ -z "$process_file_path" ]]
    then
        echo "Exiting."
        exit 1
    elif ! [[ -d "$process_file_path" ]]
    then
        mkdir -p "$process_file_path"
        if ! [[ -d "$process_file_path" ]]
        then
            echo "daemonize_script: Could not create directory for \$process_file_path."
            echo "Exiting."
            exit 1
        fi
    elif [[ -z "$process_file_prefix" ]]
    then
        echo "daemonize_script: \$process_file_prefix is not set."
        echo "Exiting."
        exit 1
    elif [[ -n "$log_file_stdout" ]] && ! [[ -f "$log_file_stdout" ]]
    then
        echo "daemonize_script: \$log_file_stdout is not a file."
        echo "log_file_stdout: $log_file_stdout"
        echo "Exiting."
        exit 1
    fi
}

kill_daemonized_script()
{
    local input="$1"

    _check_kill_daemonized_script_variables

    if [[ "$input" == 'all' ]]
    then
        _kill_all_daemonized_script
    else
        _kill_specific_daemonized_script "$input"
    fi
}

_check_kill_daemonized_script_variables()
{
    local re='^[0-9]+$'
    if ! [[ "$input" =~ $re ]] && \
       ! [[ "$input" == 'all' ]]
    then
        echo "kill_daemonized_script: Input must be either a process id or 'all'"
        echo "Exiting."
        exit 1
    elif [[ -z "$process_file_path" ]]
    then
        echo "kill_daemonized_script: \$process_file_path is not set"
        echo "Exiting."
        exit 1
    elif [[ -z "$process_file_prefix" ]]
    then
        echo "kill_daemonized_script: \$process_file_prefix is not set"
        echo "Exiting."
        exit 1
    fi
}

_kill_specific_daemonized_script()
{
    local input="$1"
    local re='^[0-9]+$'
    if [[ "$input" =~ $re ]]
    then # Is a number

        if ps -p $input >/dev/null 2>&1
        then # Process exist

            if kill "$input"
            then
                echo "Killed process id: $input"
                return 0
            else
                echo "Could not kill given process id: $input"
                return 2
            fi
        else
            echo "Found no process with corresponding process id: $input"
            return 3
        fi
    fi
}

_kill_all_daemonized_script()
{
    local ret_val

    # Find files previously created files indicating daemon process
    process_files="$(find $process_file_path -name ${process_file_prefix}*)"
    if [[ -z "$process_files" ]]
    then
        echo "Did not find any daemon process file under:"
        echo "    $process_file_path"
        echo "There is thereby no info about any running process."
        echo "Nothing killed."
        exit 1
    fi

    while IFS= read -r file
    do
        # Get everything after last '-' in file name
        process_id="${file##*-}"

        re='^[0-9]+$'
        [[ "$process_id" =~ $re ]] || continue

        echo -e "\nFound previously created daemon process file:"
        echo "    $file"

        _kill_specific_daemonized_script "$process_id"; ret_val=$?

        case $ret_val in
            0)
                rm "$process_file_path/${process_file_prefix}-${process_id}"
                ;;
            2) # Could not kill process id
                echo "Consider removing the daemon process file manually:"
                echo "    $file"
                ;;
            3) # Found no corresponding process id
                echo "Removing daemon process file:"
                echo "    $file"
                command rm "$file"
                ;;
            *)
                echo "_kill_all_daemonized_script: Unknown return value of _kill_specific_daemonized_script."
                echo "Exiting."
                exit 1
                ;;
        esac

    done <<< "$process_files"
}