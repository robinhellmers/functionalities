#!/usr/bin/env bash

main()
{
    echo "main: Start"
    echo -e "main: Execute secondary.sh with bash\n"
    bash secondary.sh
    echo -e "\nmain: return value: $?"
    echo -e "main: Source secondary.sh\n"
    source secondary.sh
    echo -e "\nmain: return value: $?"
    echo -e "main: End"
}

main

