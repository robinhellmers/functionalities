#!/usr/bin/env bash

func()
{
    echo "func: Start"
    unset -f func
    echo "func: End"
}

main()
{
    echo "main: Start"
    func
    echo "main: Mid"
    func
    echo "main: End"
}

main
