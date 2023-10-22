# Debug mode on
# set -x

# Arrays to store function-specific details
declare -a registered_function_names=()
declare -a registered_function_short_option=()
declare -a registered_function_long_option=()
declare -a registered_function_values=()

# Register valid options for a function
register_function_options() {
    echo "=== REGISTER FUNCTION OPTIONS ==="

    local function_name="$1"

    for registered in "${registered_function_names[@]}"
    do
        if [[ "$function_name" == "$registered" ]]
        then
            echo "ERROR: Function name already registered: '$function_name'"
            exit 1
        fi
    done
    shift  # Shift past the function name

    local short_option=()
    local long_option=()
    local expect_value=()
    while [[ "$#" -gt 1 ]]; do
        echo "Parsing short option: $1"
        echo "Parsing long option: $2"
        echo "Parsing value: $3"

        [[ -z "$1" ]] && short_option+=("_") || short_option+=("$1")
        [[ -z "$2" ]] && long_option+=("_") || long_option+=("$2")
        [[ -z "$3" ]] && expect_value+=("_") || expect_value+=("$3")
        
        shift 3  # Move past option, long option, and value expectation
    done

    registered_function_names+=("$function_name")
    registered_function_short_option+=("${short_option[*]}")
    registered_function_long_option+=("${long_option[*]}")
    registered_function_values+=("${expect_value[*]}")

    echo "Final Short Options: ${short_option[*]}"
    echo "Final Long Options: ${long_option[*]}"
    echo "Final Expect value: ${expect_value[*]}"
}

# Process options
_handle_args() {
    echo "=== HANDLE ARGS ==="

    local calling_function="$1"; shift
    echo "Calling Function: $calling_function"

    local index=-1
    for i in "${!registered_function_names[@]}"; do
        if [[ "${registered_function_names[$i]}" == "$calling_function" ]]; then
            index=$i
            break
        fi
    done

    (( "$index" == -1 )) && return  # Return if the function wasn't registered

    echo "len registered_function_short_option: ${#registered_function_short_option[@]}"
    for o in "${registered_function_short_option[@]}"
    do
        echo " !!!!!!!! registered_function_short_option: $o"
    done
    echo "len registered_function_long_option: ${#registered_function_long_option[@]}"
    for o in "${registered_function_long_option[@]}"
    do
        echo " !!!!!!!! registered_function_long_option: $o"
    done
    echo "len registered_function_values: ${#registered_function_values[@]}"
    for o in "${registered_function_values[@]}"
    do
        echo " !!!!!!!! registered_function_values: $o"
    done

    IFS=' ' read -ra valid_short_options <<< "${registered_function_short_option[$index]}"
    IFS=' ' read -ra valid_long_option <<< "${registered_function_long_option[$index]}"
    IFS=' ' read -ra expects_value <<< "${registered_function_values[$index]}"

    echo "Handling options: ${valid_short_options[*]}"
    echo "Handling long options: ${valid_long_option[*]}"
    echo "Handling values: ${expects_value[*]}"

    echo "valid_long_option 1: ${valid_long_option[0]}"
    echo "valid_long_option 2: ${valid_long_option[1]}"

    # Initialize flags and values
    for i in "${!valid_short_options[@]}"; do
        local derived_flag_name=""

        # Prefer the long option name if it exists
        if [[ "${valid_long_option[$i]}" != "_" ]]; then
            derived_flag_name="$(echo "${valid_long_option[$i]#--}" | tr -d '-' )_flag"
        else
            derived_flag_name="$(echo "${valid_short_options[$i]}" | tr -d '-' )_flag"
        fi

        if [[ ! ${!derived_flag_name+x} ]]; then
            echo "Initialized: $derived_flag_name=false"
            declare -g "$derived_flag_name"=false
            [[ "${expects_value[$i]}" == "true" ]] && declare -g "${derived_flag_name}_value"=""
        fi
    done

    while [[ "${1:-}" != "" ]]; do
        local was_option_handled=false

        for i in "${!valid_short_options[@]}"; do
            local derived_flag_name=""
            if [[ "$1" == "${valid_long_option[$i]}" ]] || [[ "$1" == "${valid_short_options[$i]}" ]]; then
                echo "Found option: $1"
                # If both exists e.g. $1 == -e but also --echo exists,
                # then prefer the long option

                # Prefer the long option name if it exists
                if [[ "${valid_long_option[$i]}" != "_" ]]; then
                    derived_flag_name="$(echo "${valid_long_option[$i]#--}" | tr -d '-' )_flag"
                else
                    derived_flag_name="$(echo "${valid_short_options[$i]}" | tr -d '-' )_flag"
                fi

                declare -g "$derived_flag_name"=true  # Set the flag to true

                if [[ "${expects_value[$i]}" == "true" ]]; then
                    shift
                    if [[ "${1:-}" == "" || "${1:0:1}" == "-" ]]; then
                        echo "Error: Option ${valid_short_options[$i]} (or ${valid_long_option[$i]}) expects a value"
                        exit 1
                    fi
                    declare -g "${derived_flag_name}_value"="$1"  # Storing the value in a separate variable
                fi

                was_option_handled=true
                break
            fi
        done

        if [[ "$was_option_handled" == "false" ]]; then
            non_optional_args+=("$1")
        else
            shift
            continue
        fi

        shift
    done

    # Debugging output for all the flags after they've been processed:
    echo DEBYG
    for i in "${!valid_short_options[@]}"; do
        local derived_flag_name="$(echo "${valid_short_options[$i]}" | tr -d '-' )_flag"
        [[ "${derived_flag_name}" == "_flag" ]] && derived_flag_name="$(echo "${valid_long_option[$i]}" | tr -d '-' )_flag"
        echo "$derived_flag_name: ${!derived_flag_name}"
    [[ "${expects_value[$i]}" == "true" ]] && echo "${derived_flag_name}_value: ${!derived_flag_name}_value"
    done
}

# Register function-specific options
register_function_options "func1" -e --echo "true" \
                          "" --noop "true" \
                          -p "" "true"



# Define and use functions
func1() {
    echo "=== FUNC1 ==="
    _handle_args "func1" "$@"
    echo
    echo "echo_flag: $echo_flag"
    echo "echo_flag_value: $echo_flag_value"
    echo "noop_flag: $noop_flag"
    echo "noop_flag_value: $noop_flag_value"
    echo "p_flag: $p_flag"
    echo "p_flag_value: $p_flag_value"
}

echo
# Test
func1 -e "Test Echo" --noop "No Operation" -p "Potato"
