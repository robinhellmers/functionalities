#!/usr/bin/env bash

SOURCEABLE_SCRIPT='false'

unset -f check_if_sourcable

if [[ "$SOURCEABLE_SCRIPT" != 'true' && ! "${BASH_SOURCE[0]}" -ef "$0" ]]
then
    if ! [[ "${BASH_SOURCE[0]}" -ef "$0" ]]
    then
        echo "Do not source this script! Execute it with bash instead."
        exit 1
    fi
fi
unset SOURCEABLE_SCRIPT

echo "Secondary here"
