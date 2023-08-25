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

#####################
### Library start ###
#####################

# For multiline variable definition
#
# Example without evaluation:
# define my_var <<'END_OF_MESSAGE_WITHOUT_EVAL'
# First line
# Second line $var
# END_OF_MESSAGE_WITHOUT_EVAL
#
# Example with evaluation:
# define my_var <<END_OF_MESSAGE_WITH_EVAL
# First line
# Second line $var
# END_OF_MESSAGE_WITH_EVAL
define()
{
    IFS='\n' read -r -d '' ${1} || true
}

get_func_def_line_num()
{
    local func_name=$1
    local script_file=$2

    local output_num

    output_num=$(grep -c "^[\s]*${func_name}()" $script_file)
    (( output_num == 1 )) || { echo '?'; return 1; }

    grep -n "^[\s]*${func_name}()" $script_file | cut -d: -f1
}

invalid_function_usage()
{
    local function_usage="$1"
    local error_info="$2"

    # Function index 1 represents the function call before this function
    local index=1

    local func_name="${FUNCNAME[index]}"
    local func_call_file="${BASH_SOURCE[index+1]}"
    local func_call_line_num="${BASH_LINENO[index]}"
    local func_def_file="${BASH_SOURCE[index]}"
    local func_def_line_num="$(get_func_def_line_num $func_name $func_def_file)"

    local wrapper='###################################################'
    local divider='---------------------------------------------------'

    cat >&2 <<END_OF_VARIABLE_WITH_EVAL

${wrapper}
!! Invalid usage of ${func_name}()

Called from:
${func_call_line_num}: ${func_call_file}
Defined at:
${func_def_line_num}: ${func_def_file}

${divider}
Error info:

${error_info}

${divider}
Usage info:

${function_usage}
${wrapper}
END_OF_VARIABLE_WITH_EVAL
}
