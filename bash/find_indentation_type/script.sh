#!/bin/bash

main()
{
    test_files=()
    test_files+=("example_1")
    test_files+=("example_2")
    test_files+=("example_3")

    for file in "${test_files[@]}"
    do
        echo ""
        echo "Testing functionalities on the file: $file"

        find_indent "$file"
    done
    echo ""
}

# Function to find the most common indentation type
find_indent_type()
{
    local file="$1"
    local spaces_indent=$(grep -c '^ \+' "$file")
    local tabs_indent=$(grep -c $'^\t' "$file")
    (( spaces_indent > tabs_indent )) && echo "spaces" || echo "tabs"
}

# Function to find the indentation size if the indentation type is spaces
# Will find the smallest indentation size using spaces
find_indent_size()
{
    local file="$1"
    # Find all leading spaces for each line in the file
    local leading_spaces=$(grep -oP '^( +)' "$file")
    # Calculate the length of each leading space string
    local leading_spaces_lengths=$(echo "$leading_spaces" | awk '{print length}')
    # Sort the lengths numerically
    local sorted_lengths=$(echo "$leading_spaces_lengths" | sort -n)
    # Find the unique lengths and count their occurrences
    local unique_lengths=$(echo "$sorted_lengths" | uniq -c)
    # Extract only the lengths
    local lengths=$(echo "$unique_lengths" | awk '{print $2}')
    # Find the smallest length
    local indent_size=$(echo "$lengths" | head -n1)
    echo "$indent_size"
}

find_indent()
{
    local file="$1"
    local indent_type=$(find_indent_type "$file")
    echo "Indentation type: $indent_type"

    if [[ $indent_type == "spaces" ]]; then
        local indent_size=$(find_indent_size "$file")
        echo "Indentation size: $indent_size"
    fi
}

### Call main() ###
main "$@"
###################