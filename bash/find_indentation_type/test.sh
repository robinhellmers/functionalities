#!/bin/bash

source main.sh

main()
{
    test_files_location="test_files"

    test_files=()
    test_files+=("$test_files_location/example_1")
    test_files+=("$test_files_location/example_2")
    test_files+=("$test_files_location/example_3")

    for file in "${test_files[@]}"
    do
        echo ""
        echo "Testing functionalities on the file: $file"

        find_indent "$file"
    done
    echo ""
}

### Call main() ###
main "$@"
###################