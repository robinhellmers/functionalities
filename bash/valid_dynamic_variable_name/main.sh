#!/usr/bin/env bash


main()
{
    var_name="some1var_name3"
    valid_var_name "$var_name" && echo yes || echo no

    var_name="2some1var_name3"
    valid_var_name "$var_name" && echo yes || echo no

    var_name="some1var_name3"
    valid_var_name "$var_name" && echo yes || echo no
    
    var_name="s?some1var_name3"
    valid_var_name "$var_name" && echo yes || echo no

    var_name=""
    valid_var_name "$var_name" && echo yes || echo no
}

valid_var_name() {
    grep -q '^[_[:alpha:]][_[:alpha:][:digit:]]*$' <<< "$1"
}

main
