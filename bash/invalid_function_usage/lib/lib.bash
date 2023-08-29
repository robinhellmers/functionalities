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

backtrace()
{
    # Top level function name
    local top_level_function='main'

    local line
    local backtrace_output
    # 1 or 0 depending if to include 'backtrace' function in call stack
    # 0 = include 'backtrace' function
    local i=1
    until [[ "${FUNCNAME[$i]}" == "$top_level_function" ]]
    do
        line="#${i}  '${FUNCNAME[$i]}' at  ${BASH_LINENO[$i]}: ${BASH_SOURCE[i+1]}"

        if [[ -z "$backtrace_output" ]]
        then
            # Before backtrace_output is defined
            backtrace_output="$line"
        else
            printf -v backtrace_output "%s\n${line}" "$backtrace_output"
        fi
        ((i++))
    done

    echo "$backtrace_output"
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
    if [[ -z "$function_usage"  || -z "$error_info" ]]
    then
        # Usage error of this function
        index=0
        input_error_this_func='true'

        error_info="None or only one argument was entered."

        define function_usage <<'END_OF_VARIABLE_WITHOUT_EVAL'
Usage: invalid_function_usage <function_usage> <error_info>
    <function_usage>:
        - Multi-line description on how to use the function, create multi-line
          variable using define() and pass that variable to the function.
            * Example:

              define function_usage <<'END_OF_VARIABLE'
              Usage: "Function name" <arg1> <arg2>
                  <arg1>:
                      - "arg1 option 1" / "arg1 description"
                  <arg2>:
                      - "arg2 option 1"
                      - "arg2 option 2"
              END_OF_VARIABLE

    <error_info>:
        - Single-/Multi-line with extra info.
            * Example:
              "Invalid input <arg2>: '$arg_two'"
END_OF_VARIABLE_WITHOUT_EVAL
    fi

    local func_name="${FUNCNAME[index]}"
    local func_call_file="${BASH_SOURCE[index+1]}"
    local func_call_line_num="${BASH_LINENO[index]}"
    local func_def_file="${BASH_SOURCE[index]}"
    local func_def_line_num="$(get_func_def_line_num $func_name $func_def_file)"

    eval $(resize) # Update COLUMNS regardless if shopt checkwinsize is enabled
    local wrapper="$(printf "%.s#" $(seq $COLUMNS))"
    local divider="$(printf "%.s-" $(seq $COLUMNS))"
    local wrapper_start=$(printf "$wrapper\n##")
    local wrapper_end=$(printf "##\n$wrapper")

    # Remove potential last whitespace line
    function_usage=$(sed '${/^[[:space:]]*$/d;}' <<< ${function_usage})

    cat >&2 <<END_OF_VARIABLE_WITH_EVAL

${wrapper_start} !! Invalid usage of ${func_name}()

Called from:
${func_call_line_num}: ${func_call_file}
Defined at:
${func_def_line_num}: ${func_def_file}

Whole backtrace:
$(backtrace)

${divider}
Error info:

${error_info}

${divider}
Usage info:

${function_usage}
${wrapper_end}
END_OF_VARIABLE_WITH_EVAL
}
