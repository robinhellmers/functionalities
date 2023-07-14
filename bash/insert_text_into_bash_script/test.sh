#!/bin/bash

# Load insert_text function from insert_text.sh script
source insert_text.sh

# Specify file to insert text into
file="test_files/advanced_script.sh"

# Insert text at different relevant and challenging places in the file
read -r -d '' text << EOM
# Inserting text after variable definitions...
echo "Inserted text"
EOM
echo "Inserting text after variable definitions..."
insert_text "$file" 6 "$text"

read -r -d '' text << EOM
# Inserting text inside function definition...
echo "Inserted text"
EOM
echo "Inserting text inside function definition..."
insert_text "$file" 11 "$text"

read -r -d '' text << EOM
# Inserting text inside nested if statement...
echo "Inserted text"
EOM
echo "Inserting text inside nested if statement..."
insert_text "$file" 16 "$text"

read -r -d '' text << EOM
# Inserting text inside for loop...
echo "Inserted text"
EOM
echo "Inserting text inside for loop..."
insert_text "$file" 26 "$text"

read -r -d '' text << EOM
# Inserting text inside nested while loop...
echo "Inserted text"
EOM
echo "Inserting text inside nested while loop..."
insert_text "$file" 32 "$text"

read -r -d '' text << EOM
# Inserting text inside if statement...
echo "Inserted text"
EOM
echo "Inserting text inside if statement..."
insert_text "$file" 41 "$text"

read -r -d '' text << EOM
# Inserting text inside while loop...
echo "Inserted text"
EOM
echo "Inserting text inside while loop..."
insert_text "$file" 51 "$text"

echo "Done inserting text."
