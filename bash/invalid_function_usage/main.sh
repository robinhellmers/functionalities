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
    local phrase

    phrase='Whatsup'
    echo -e "\nTry to welcome 1st group of people with '$phrase'"
    welcome_people 1 0 "$phrase"

    phrase='Hello'
    echo -e "\nTry to welcome 2nd group of people with '$phrase'"
    welcome_people 1 1 "$phrase"

    phrase='Whatsup'
    echo -e "\nTry to welcome 3rd group of people with '$phrase'"
    welcome_people 1 1 "$phrase"

    echo -e "\nUse invalid argument for invalid_function_usage():"
    invalid_function_usage asd
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

# No checks in welcome_people()
welcome_people()
{
    local num_friends=$1
    local num_colleagues=$2
    local phrase="$3"

    echo "Group of people:"
    echo "    $num_friends friends"
    echo "    $num_colleagues colleagues"
    echo

    for ((i=0; i < num_friends; i++))
    do
        welcome_friend "$phrase"
    done

    for ((i=0; i < num_colleagues; i++))
    do
        welcome_colleague "$phrase"
    done
}

welcome_friend()
{
    local friendly_phrase="$1"

    define function_usage <<'END_OF_FUNC_USAGE'
Usage: first_func <friendly_phrase>
    <friendly_phrase>:
        - A phrase for welcoming a friend
            * 'Hello'
            * 'Hey'
            * 'Whatsup'
END_OF_FUNC_USAGE

    case "$friendly_phrase" in
        'Hello'|'Hey'|'Whatsup')
            ;;
        *)
            invalid_function_usage "$function_usage" "Invalid friendly phrase: '$friendly_phrase'"
            ;;
    esac

    echo "You welcomed a friend with '$friendly_phrase'."
}


welcome_colleague()
{
    local professional_phrase="$1"

    define function_usage <<'END_OF_FUNC_USAGE'
Usage: welcome_colleague <professional_phrase>
    <professional_phrase>:
        - A phrase for welcoming a colleague
            * 'Hello'
            * 'Hi'
END_OF_FUNC_USAGE

    case "$professional_phrase" in
        'Hello'|'Hi')
            ;;
        *)
            invalid_function_usage "$function_usage" "Invalid professional phrase: '$professional_phrase'"
            ;;
    esac

    echo "You welcomed a colleague with '$professional_phrase'."
}

#################
### Call main ###
#################
main_wrapper "$@"
#################
