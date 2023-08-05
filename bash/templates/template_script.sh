#!/usr/bin/env bash

readonly SOURCEABLE_SCRIPT='false'

if [[ "$SOURCEABLE_SCRIPT" == 'true' && ! "${BASH_SOURCE[0]}" -ef "$0" ]]
then
    if ! [[ "${BASH_SOURCE[0]}" -ef "$0" ]]
    then
        echo "Do not source this script! Execute it with bash instead."
        return 1
    fi
fi
unset SOURCEABLE_SCRIPT

########################
### Library sourcing ###
########################

library_sourcing()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    local -r THIS_SCRIPT_PATH="$(find_script_path)"

    # Store $THIS_SCRIPT_PATH as unique or local variables
    # E.g. local -r LIB_PATH="$THIS_SCRIPT_PATH/lib"

    ### Source libraries ###

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

#####################
### Library start ###
#####################
