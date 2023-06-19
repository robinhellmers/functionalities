
handle_input_arrays_dynamically()
{
    local dynamic_array_prefix="$1"; shift
    local array_suffix=1
    while (( $# )) ; do
        local num_args=$1; shift
        while (( num_args-- > 0 )) 
        do
            eval "$dynamic_array_prefix$array_suffix+=(\"\$1\")"; shift
        done
        ((array_suffix++))
    done
}

get_dynamic_element()
{
    local array_name="$1"
    local index="$2"

    dynamic_array_element=$(eval "echo \"\${$array_name[$index]}\"")
    echo "$dynamic_array_element"
}

get_dynamic_array()
{
    local array_name="$1"

    dynamic_array=()
    dynamic_array_len="$(get_dynamic_array_len $array_name)"
    for (( i=0; i < dynamic_array_len; i++ ))
    do
        dynamic_array+=("$(get_dynamic_element $array_name $i)")
    done
}

get_dynamic_array_len()
{
    local array_name="$1"

    dynamic_array_len=$(eval "echo \${#$array_name[@]}")
    echo "$dynamic_array_len"
}
