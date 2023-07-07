#!/usr/bin/env bash

source function_array_parameters.sh

main()
{
    array_one=("Canberra" "Buenos Aires" "Stockholm")
    array_two=("Rose" "Peruvian Lily" "Orchid")
    array_three=("Gummy bears" "Skittles" "Snickers")
    array_four=(5 4 3)
    array_five=("Indigo" "Khaki" "Forest green")

    echo "****************************"
    echo "***** Test iteration 1 *****"
    echo "****************************"
    test_function \
        "${#array_one[@]}" "${array_one[@]}" \
        "${#array_two[@]}" "${array_two[@]}" \
        "${#array_three[@]}" "${array_three[@]}" \
        "${#array_four[@]}" "${array_four[@]}" \
        "${#array_five[@]}" "${array_five[@]}"
    
    echo -e "\n"
    echo "****************************"
    echo "***** Test iteration 2 *****"
    echo "****************************"
    test_function \
        "${#array_one[@]}" "${array_one[@]}" \
        "${#array_two[@]}" "${array_two[@]}" \
        "${#array_three[@]}" "${array_three[@]}" \
        "${#array_four[@]}" "${array_four[@]}" \
        "${#array_five[@]}" "${array_five[@]}"
}

# 1: Capital cities
# 2: Flower names
# 3: Candy names
# 4: Numbers
# 5: Colors
test_function()
{
    dynamic_array_prefix="input_array"
    handle_input_arrays_dynamically "$dynamic_array_prefix" "$@"

    # Explicitly write out the array prefix + suffix
    local capital_cities=("${input_array1[@]}")

    # Get all the elements using the variable containing the array prefix
    get_dynamic_array "${dynamic_array_prefix}2"
    local flower_names=("${dynamic_array[@]}")

    # Get each element one by one, by echo
    local candy_names=()
    candy_names+=("$(get_dynamic_element "${dynamic_array_prefix}3" 0)")
    candy_names+=("$(get_dynamic_element "${dynamic_array_prefix}3" 1)")
    candy_names+=("$(get_dynamic_element "${dynamic_array_prefix}3" 2)")

    # Get each element one by one, through variable created
    local numbers=()
    get_dynamic_element "${dynamic_array_prefix}4" 0 > /dev/null
    numbers+=("$dynamic_array_element")
    get_dynamic_element "${dynamic_array_prefix}4" 1 > /dev/null
    numbers+=("$dynamic_array_element")
    get_dynamic_element "${dynamic_array_prefix}4" 2 > /dev/null
    numbers+=("$dynamic_array_element")

    # Get length and loop
    local color_names=()
    get_dynamic_array_len "${dynamic_array_prefix}5" > /dev/null
    color_names_len="$dynamic_array_len"
    for (( i=0; i < color_names_len; i++ ))
    do
        color_names+=("${input_array5[i]}")
    done



    echo "Capital cities:"
    array_to_print=("${capital_cities[@]}")
    print_array 
 
    echo "Flower names:"
    array_to_print=("${flower_names[@]}")
    print_array

    echo "Candy names:"
    array_to_print=("${candy_names[@]}")
    print_array

    echo "Numbers:"
    array_to_print=("${numbers[@]}")
    print_array

    echo "Length of color names array: $color_names_len"
    echo "Color names:"
    array_to_print=("${color_names[@]}")
    print_array
}

print_array()
{
    for element in "${array_to_print[@]}"
    do
        echo "* $element"
    done
    echo ""
}

### Call main() ###
main
###################