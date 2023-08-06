#!/usr/bin/env bash

main()
{
    echo "test: Start"
    echo -e "test: Source first time\n"

    source main.sh
    
    echo -e "\ntest: Source second time\n"

    source main.sh

    echo -e "\ntest: End"
}

main