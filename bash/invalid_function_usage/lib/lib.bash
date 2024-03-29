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
    # 1 or 0 depending if to include 'backtrace' function in call stack
    # 0 = include 'backtrace' function
    local callstack_level=1
    # Top level function name
    local top_level_function='main'

    local iter_part_template
    local func_name_part_template
    local line_num_part_template
    local file_part_template

    define iter_part_template <<'EOM'
iter_part="#${i}  "
EOM
    define func_name_part_template <<'EOM'
func_name_part="'${FUNCNAME[$i]}' "
EOM
    define line_num_part_template <<'EOM'
line_num_part="  ${BASH_LINENO[$i]}:"
EOM
    define file_part_template <<'EOM'
file_part=" ${BASH_SOURCE[i+1]}"
EOM

    ### Find max lengths of parts in order to later find whitespacing needed
    #
    local iter_part
    local func_name_part
    local line_num_part
    local file_part
    local iter_len
    local func_name_len
    local line_num_len
    local i=$callstack_level
    local iter_maxlen=0
    local func_name_maxlen=0
    local line_num_maxlen=0
    until [[ "${FUNCNAME[$i]}" == "$top_level_function" ]]
    do
        eval "$iter_part_template"
        eval "$func_name_part_template"
        eval "$line_num_part_template"
        eval "$file_part_template"

        iter_len=$(wc -m <<< "$iter_part")
        ((iter_len--))
        func_name_len=$(wc -m <<< "$func_name_part")
        ((func_name_len--))
        line_num_len=$(wc -m <<< "$line_num_part")
        ((line_num_len--))


        ((iter_len > iter_maxlen)) && iter_maxlen=$iter_len
        ((func_name_len > func_name_maxlen)) && func_name_maxlen=$func_name_len
        ((line_num_len > line_num_maxlen)) && line_num_maxlen=$line_num_len

        ((i++))
    done

    ### Construct lines with good whitespacing using max lengths
    #
    local diff_len
    local extra_whitespace
    local line
    local backtrace_output
    # 1 or 0 depending if to include 'backtrace' function in call stack
    # 0 = include 'backtrace' function
    local i=1
    until [[ "${FUNCNAME[$i]}" == "$top_level_function" ]]
    do
        eval "$iter_part_template"
        eval "$func_name_part_template"
        eval "$line_num_part_template"
        eval "$file_part_template"

        iter_len=$(wc -m <<< "$iter_part")
        ((iter_len--))

        # Check if to add extra whitespace after 'iter_part'
        if ((iter_len < iter_maxlen))
        then
            diff_len=$((iter_maxlen - iter_len))
            extra_whitespace="$(printf "%.s " $(seq $diff_len))"
            iter_part="${iter_part}${extra_whitespace}"
        fi

        func_name_len=$(wc -m <<< "$func_name_part")
        ((func_name_len--))

        # Check if to add extra whitespace after 'func_name_part'
        if ((func_name_len < func_name_maxlen))
        then
            diff_len=$((func_name_maxlen - func_name_len))
            extra_whitespace="$(printf "%.s " $(seq $diff_len))"
            func_name_part="${func_name_part}${extra_whitespace}"
        fi

        line_num_len=$(wc -m <<< "$line_num_part")
        ((line_num_len--))

        # Check if to add extra whitespace before 'line_num_part'
        if ((line_num_len < line_num_maxlen))
        then
            diff_len=$((line_num_maxlen - line_num_len))
            extra_whitespace="$(printf "%.s " $(seq $diff_len))"
            line_num_part="${extra_whitespace}${line_num_part}"
        fi

        line="${iter_part}${func_name_part}at${line_num_part}${file_part}"

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

command_exists()
{
    type "$1" >/dev/null 2>&1
}

# 'echo_stderr' writes directly to 'stderr' compared to
# 'echo >&2' which writes to 'stdout' and then redirects to 'stderr'.
# As the Github project 'stderred'
#     https://github.com/ku1ik/stderred
# only colorizes text which is written to 'stderr' directly, it needs
# 'echo_stderr' to work properly. 'stderred' coloring is preferred as that
# will not mess with the order of 'stdout' vs 'stderr' compared to
# redirecting to 'stderr' and then using 'sed' to color it.
echo_error()
{
    local output="$1"
    command_exists echo_stderr && echo_stderr "$output" || echo "$output" >&2
}

invalid_function_usage()
{
    local function_usage="$1"
    local error_info="$2"

    # Function index 1 represents the function call before this function
    local index=1
    local input_error_this_func='false'
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

    local output
    define output <<END_OF_VARIABLE_WITH_EVAL

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

    echo_error "$output"

    [[ "$input_error_this_func" == 'true' ]] && exit 1
}
