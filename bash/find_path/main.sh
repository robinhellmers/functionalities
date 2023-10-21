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
    unset -f library_sourcing

    local -r THIS_SCRIPT_PATH="$(tmp_find_script_path)"

    # Store $THIS_SCRIPT_PATH as unique or local variables
    # LIB_PATH is needed by sourced libraries as well
    readonly PROJECT_BASE_PATH="$THIS_SCRIPT_PATH"
    export PROJECT_BASE_PATH
    readonly LIB_PATH="$THIS_SCRIPT_PATH/lib"
    export LIB_PATH

    ### Source libraries ###
    source "$LIB_PATH/lib_core.bash"
    source "$LIB_PATH/lib.bash"
}

# Minimal version of find_path().
# Should only be used within this script to source library defining find_path().
tmp_find_script_path()
{
    unset -f tmp_find_script_path
    local bash_source="${BASH_SOURCE[0]}"

    local this_script_path this_script script_called_from_path
    while [ -L "$bash_source" ]; do # resolve $bash_source until the file is no longer a symlink
        this_script_path=$( cd -P "$( dirname "$bash_source" )" >/dev/null 2>&1 && pwd )
        bash_source=$(readlink "$bash_source")
        # If $bash_source was a relative symlink, we need to resolve it relative
        # to the path where the symlink file was located
        [[ $bash_source != /* ]] && bash_source=$this_script_path/$bash_source 
    done
    echo "$( cd -P "$( dirname "$bash_source" )" >/dev/null 2>&1 && pwd )"
}

# tmp_find_script_path() {
#     unset -f tmp_find_script_path; local s="${BASH_SOURCE[0]}"; local d
#     while [ -L "$s" ]; do d=$(cd -P "$(dirname "$s")" &>/dev/null && pwd); s=$(readlink "$s"); [[ $s != /* ]] && s=$d/$s; done
#     echo "$(cd -P "$(dirname "$s")" &>/dev/null && pwd)"
# }

library_sourcing

############
### MAIN ###
############
main()
{
    echo ""
    echo "*********** This is main.sh ***********"
    tmp="$(find_path 'this_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
    echo "find_path 'this_file':      $tmp"
    tmp="$(find_path 'this' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
    echo "find_path 'this':           $tmp"
    tmp="$(find_path 'last_exec_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
    echo "find_path 'last_exec_file': $tmp"
    tmp="$(find_path 'last_exec' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
    echo "find_path 'last_exec':      $tmp"
    echo ""
    
    echo ""
    echo "*********** This is main.sh ***********"
    echo "Source multiple nested scripts"
    echo "main.sh will source a/a.sh"
    echo "a/a.sh  will source b/b.sh"
    echo "b/b.sh  will source c/c.sh"
    echo ""
    echo "Sourcing a/a.sh..."
    source $PROJECT_BASE_PATH/a/a.sh

    echo ""
    echo "*********** This is main.sh ***********"
    echo "Execute multiple nested scripts"
    echo "main.sh  will execute a/aa.sh"
    echo "a/aa.sh  will execute b/bb.sh"
    echo "b/bb.sh  will execute c/cc.sh"
    echo ""
    echo "Executing a/aa.sh..."
    bash $PROJECT_BASE_PATH/a/aa.sh

    echo ""
    echo "*********** This is main.sh ***********"
    echo "Execute and source multiple nested scripts"
    echo "main.sh   will execute a/aaa.sh"
    echo "a/aaa.sh  will source  b/bbb.sh"
    echo "b/bbb.sh  will execute c/ccc.sh"
    echo ""
    echo "Executing a/aaa.sh"
    bash $PROJECT_BASE_PATH/a/aaa.sh

    echo ""
    echo "*********** This is main.sh ***********"
    echo "Execute and source multiple nested scripts"
    echo "main.sh    will source  a/aaaa.sh"
    echo "a/aaaa.sh  will execute b/bbbb.sh"
    echo "b/bbbb.sh  will source  c/cccc.sh"
    echo ""
    echo "Sourcing a/aaaa.sh"
    source $PROJECT_BASE_PATH/a/aaaa.sh

    echo ""
    echo "*********** This is main.sh"
    echo "Call find_path() with invalid 'bash_source'"
    tmp="$(find_path 'this')"
}
###################
### END OF MAIN ###
###################

main_stderr_red()
{
    main "$@" 2> >(sed $'s|.*|\e[31m&\e[m|' >&2)
}

#################
### Call main ###
#################
main_stderr_red "$@"
#################
