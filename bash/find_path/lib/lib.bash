#####################
### Guard library ###
#####################
guard_source_max_once()
{
    valid_var_name() { grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' <<< "$1"; }

    local file_name="$(basename "${BASH_SOURCE[0]}")"
    local file_name_wo_extension="${file_name%.*}"
    local guard_var_name="guard_$file_name_wo_extension"

    if ! valid_var_name "$guard_var_name"
    then
        echo "Failed at creating valid variable name for guarding library."
        echo -e "File name: $file_name\nVariable name: $guard_var_name"
        exit 1
    fi

    [[ -n "${!guard_var_name}" ]] && return 1
    declare -gr "guard_$file_name_wo_extension=true"
}

guard_source_max_once || return

##############################
### Library initialization ###
##############################
init_lib()
{
    # Unset as only called once and most likely overwritten when sourcing libs
    unset -f init_lib

    if ! [[ -d "$LIB_PATH" ]]
    then
        echo "LIB_PATH is not defined to a directory for the sourced script."
        echo "LIB_PATH: '$LIB_PATH'"
        exit 1
    fi

    ### Source libraries ###
    #
    # Always start with 'lib_core.bash'
    source "$LIB_PATH/lib_core.bash"
}

init_lib

#####################
### Library start ###
#####################

echo ""
echo "*********** This is lib/lib.bash ***********"
tmp="$(find_path 'this_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'this_file':      $tmp"
tmp="$(find_path 'this' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'this':           $tmp"
tmp="$(find_path 'last_exec_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'last_exec_file': $tmp"
tmp="$(find_path 'last_exec' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'last_exec':      $tmp"
echo ""
