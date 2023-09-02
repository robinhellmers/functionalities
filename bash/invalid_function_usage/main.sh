#!/usr/bin/env bash

sourceable_script='false'

if [[ "$sourceable_script" != 'true' && ! "${BASH_SOURCE[0]}" -ef "$0" ]]
then
    echo "Do not source this script! Execute it with bash instead."
    return 1
fi
unset sourceable_script

########################
### Library sourcing ###
########################

library_sourcing()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    local -r THIS_SCRIPT_PATH="$(find_script_path)"

    # Store $THIS_SCRIPT_PATH as unique or local variables
    local -r LIB_PATH="$THIS_SCRIPT_PATH/lib"

    ### Source libraries ###
    source "$LIB_PATH/lib.bash"
}

# Only store output in multi-file unique readonly global variables or
# local variables to avoid variable values being overwritten in e.g.
# sourced library files.
# Recommended to always call the function when to use it
find_script_path()
{
    local this_script_path
    local bash_source="${BASH_SOURCE[0]}"

    while [ -L "$bash_source" ]; do # resolve $bash_source until the file is no longer a symlink
        this_script_path=$( cd -P "$( dirname "$bash_source" )" >/dev/null 2>&1 && pwd )
        bash_source=$(readlink "$bash_source")
        # If $bash_source was a relative symlink, we need to resolve it relative
        # to the path where the symlink file was located
        [[ $bash_source != /* ]] && bash_source=$this_script_path/$bash_source 
    done
    this_script_path=$( cd -P "$( dirname "$source" )" >/dev/null 2>&1 && pwd )

    echo "$this_script_path"
}

library_sourcing

############
### MAIN ###
############
main()
{
    first_func "Hey"
    first_func "Hay"

    echo -e "\nLets call invalid_function_usage() with invalid arguments."
    invalid_function_usage 'asd'
}
###################
### END OF MAIN ###
###################

main_wrapper()
{
    if command_exists stderr_red && command_exists echo_stderr
    then
        # Color stderr using Github 'stderred'
        # https://github.com/ku1ik/stderred
        stderr_red main "$@"
    elif [[ "$FORCE_STDERR_RED" == 'true' ]]
    then
        # This can mess with the order of 'stdout' vs 'stderr'
        main "$@" 2> >(sed $'s|.*|\e[31m&\e[m|' >&2)
    else
        main "$@"
    fi
}


first_func()
{
    local input="$1"

    second_func "$input"
}

second_func()
{
    local input="$1"

    third_func "$input"
}

third_func()
{
    local input="$1"

    fourth_func "$input"
}

fourth_func()
{
    local input="$1"

    sixth_func "$input"
}

sixth_func()
{
    local input="$1"

    seventh_func "$input"
}

seventh_func()
{
    local input="$1"

    eigth_func "$input"
}

eigth_func()
{
    local input="$1"

    nineth_func "$input"
}

nineth_func()
{
    local input="$1"

    tenth_func "$input"
}

tenth_func()
{
    local input="$1"

    eleventh_func "$input"
}

eleventh_func()
{
    local input="$1"

    local function_usage
    define function_usage <<'END_OF_MESSAGE'
Usage: eleventh_func <phrase>
    <phrase>:
        - 'Hi'
        - 'Hey'
END_OF_MESSAGE

    local valid_inputs=('Hi' 'Hey')
    local is_valid='false'
    for valid_input in "${valid_inputs[@]}"
    do
        [[ "$input" == "$valid_input" ]] && is_valid='true'
    done

    if [[ "$is_valid" == 'true' ]]
    then
        echo "$input"
    else
        invalid_function_usage "$function_usage" \
                               "Invalid input phrase: '$input'"
    fi
}


#################
### Call main ###
#################
main_wrapper "$@"
#################
