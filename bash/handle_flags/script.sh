# Arrays to store _handle_args() data
_handle_args_registered_function_names=()
_handle_args_registered_function_short_option=()
_handle_args_registered_function_long_option=()
_handle_args_registered_function_values=()

# Register valid options for a function
register_function_options() {
    local function_name="$1"
    shift 

    if [[ -z "$function_name" ]]
    then
        echo "ERROR: Function name is empty"
        exit 1
    fi

    for registered in "${_handle_args_registered_function_names[@]}"
    do
        if [[ "$function_name" == "$registered" ]]
        then
            echo "ERROR: Function name already registered: '$function_name'"
            exit 1
        fi
    done

    local short_option=()
    local long_option=()
    local expect_value=()
    while (( $# > 1 ))
    do

        if [[ -z "$1" ]] && [[ -z "$2"  ]]
        then
            echo "ERROR: Neither short or long option given for '$function_name'."
            exit 1
        fi

        [[ -z "$1" ]] && short_option+=("_") || short_option+=("$1")
        [[ -z "$2" ]] && long_option+=("_") || long_option+=("$2")
        [[ -z "$3" ]] && expect_value+=("_") || expect_value+=("$3")

        shift 3  # Move past option, long option, and value expectation
    done

    ### Append to global arrays
    #
    # [*] used to save all space separated at the same index, to map all options
    # to the same registered function name
    _handle_args_registered_function_names+=("$function_name")
    _handle_args_registered_function_short_option+=("${short_option[*]}")
    _handle_args_registered_function_long_option+=("${long_option[*]}")
    _handle_args_registered_function_values+=("${expect_value[*]}")
}

# Process options
_handle_args() {
    local calling_function="$1"
    shift

    if [[ -z "$calling_function" ]]
    then
        echo "ERROR: Given <calling_function> is empty."
        exit 1
    fi

    local function_registered='false'
    local function_index
    for i in "${!_handle_args_registered_function_names[@]}"
    do
        if [[ "${_handle_args_registered_function_names[$i]}" == "$calling_function" ]]
        then
            function_registered='true'
            function_index=$i
            break
        fi
    done

    if [[ "$function_registered" != 'true' ]]
    then
        echo "ERROR: Function is not registered: '$calling_function'"
        exit 1
    fi

    # Convert space separated elements into an array
    IFS=' ' read -ra valid_short_options <<< "${_handle_args_registered_function_short_option[$function_index]}"
    IFS=' ' read -ra valid_long_option <<< "${_handle_args_registered_function_long_option[$function_index]}"
    IFS=' ' read -ra expects_value <<< "${_handle_args_registered_function_values[$function_index]}"

    # Declare and initialize output variables
    # <long/short option>_flag = 'false'
    # <long/short option>_flag_value = ''
    for i in "${!valid_short_options[@]}"
    do
        local derived_flag_name=""
        
        # Find out variable naming prefix
        # Prefer the long option name if it exists
        if [[ "${valid_long_option[$i]}" != "_" ]]
        then
            derived_flag_name="${valid_long_option[$i]#--}_flag"
        else
            derived_flag_name="${valid_short_options[$i]#-}_flag"
        fi

        # Initialization
        declare -g "$derived_flag_name"='false'
        if [[ "${expects_value[$i]}" == "true" ]]
        then
            declare -g "${derived_flag_name}_value"=''
        fi
    done

    # While there are input arguments left
    while [[ -n "$1" ]]
    do
        local was_option_handled='false'

        for i in "${!valid_short_options[@]}"
        do
            local derived_flag_name=""
            if [[ "$1" == "${valid_long_option[$i]}" ]] || [[ "$1" == "${valid_short_options[$i]}" ]]
            then
                
                # Find out variable naming prefix
                # Prefer the long option name if it exists
                if [[ "${valid_long_option[$i]}" != "_" ]]
                then
                    derived_flag_name="${valid_long_option[$i]#--}_flag"
                else
                    derived_flag_name="${valid_short_options[$i]#-}_flag"
                fi

                # Indicate that flag was given
                declare -g "$derived_flag_name"='true'

                if [[ "${expects_value[$i]}" == 'true' ]]
                then
                    shift

                    local first_character_hyphen='false'
                    [[ "${1:0:1}" == "-" ]] && first_character_hyphen='true'

                    if [[ -z "$1" ]] || [[ "$first_character_hyphen" == 'true' ]]
                    then
                        echo "Error: Option ${valid_short_options[$i]} (or ${valid_long_option[$i]}) expects a value"
                        exit 1
                    fi

                    # Store given value after flag
                    declare -g "${derived_flag_name}_value"="$1"
                fi

                was_option_handled='true'
                break
            fi
        done

        [[ "$was_option_handled" == 'false' ]] && non_flagged_args+=("$1")

        shift
    done
}

# Register function-specific flags
register_function_options 'func1' \
                          '-e' '--echo' 'true' \
                          ''   '--noop' 'true' \
                          '-p' ''       'true'

func1()
{
    echo ""
    echo "=== FUNC1 ==="
    _handle_args "func1" "$@"
    echo ""
    echo "echo_flag: $echo_flag"
    echo "echo_flag_value: $echo_flag_value"
    echo ""
    echo "noop_flag: $noop_flag"
    echo "noop_flag_value: $noop_flag_value"
    echo ""
    echo "p_flag: $p_flag"
    echo "p_flag_value: $p_flag_value"
    echo ""
    echo "non_flagged_args: ${non_flagged_args[@]}"
    echo ""
}

func1 "a" -e "Test Echo" --noop "No Operation" -p "Potato" "b" "c"
