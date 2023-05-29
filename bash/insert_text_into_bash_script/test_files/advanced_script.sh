#!/bin/bash

# Define some variables
var1="Hello"
var2="World"

# Define a function
my_function() {
    echo "$var1 $var2"
    # Use a nested if statement
    if [[ $var1 == "Hello" ]]; then
        echo "var1 is Hello"
    else
        echo "var1 is not Hello"
    fi
}

# Use a for loop
for i in {1..3}; do
    echo "Iteration $i"
    # Use a nested while loop
    counter=0
    while [[ $counter -lt 3 ]]; do
        echo "Counter: $counter"
        ((counter++))
    done
done

# Use an if statement
if [[ $var1 == "Hello" ]]; then
    echo "var1 is Hello"
else
    echo "var1 is not Hello"
fi

# Use a while loop
counter=0
while [[ $counter -lt 3 ]]; do
    echo "Counter: $counter"
    ((counter++))
done

# Call the function
my_function
