#!/bin/bash

# Function to find the most common indentation type
find_indent_type() {
    local file="$1"
    local spaces_indent=$(grep -c '^ \+' "$file")
    local tabs_indent=$(grep -c $'^\t' "$file")
    (( spaces_indent > tabs_indent )) && echo "spaces" || echo "tabs"
}

# Function to find the indentation size if the indentation type is spaces
# Will find the smallest indentation size using spaces
find_indent_size() {
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

# Function to insert multiline variable text into a file at a specified line number
insert_text() {
  local file="$1"
  local line_number="$2"
  local text="$3"

  # Get indentation type and size
  indent_type=$(find_indent_type "$file")
  if [[ $indent_type == "spaces" ]]; then
      indent_size=$(find_indent_size "$file")
  else
      indent_size=1
  fi

  # Get previous line and its indentation level
  previous_line_number=$((line_number-1))
  previous_line=$(sed "${previous_line_number}q;d" "$file")
  previous_line_whitespace=$(echo "$previous_line" | grep -oP '^(\s+)')

  # Check if previous line requires additional indentation level
  if [[ $previous_line =~ do ]] && grep -qP "^\s*(for|while)\b" <(tail -n +$((previous_line_number-1)) "$file" | head -n 2); then
      if [[ $indent_type == "spaces" ]]; then
          previous_line_whitespace+=$(printf "%*s" $indent_size "")
      else
          previous_line_whitespace+=$'\t'
      fi
  elif [[ $previous_line =~ then ]] && grep -qP "^\s*if\b" <(tail -n +$((previous_line_number-1)) "$file" | head -n 2); then
      if [[ $indent_type == "spaces" ]]; then
          previous_line_whitespace+=$(printf "%*s" $indent_size "")
      else
          previous_line_whitespace+=$'\t'
      fi
  elif [[ $previous_line =~ \{$ ]]; then 
      if [[ $indent_type == "spaces" ]]; then 
          previous_line_whitespace+=$(printf "%*s" $indent_size "") 
      else 
          previous_line_whitespace+=$'\t' 
      fi 
  fi

  # Indent text and insert it into file at specified line number after opening curly brace {
  indented_text=$(echo "$text" | sed "s/^/$previous_line_whitespace/")
  if (( line_number > $(wc -l <"$file") )); then 
      printf '%s\n' "$indented_text" >>"$file"
  else 
      awk -v n="$line_number" -v s="$indented_text" 'NR == n {print s} {print}' "$file"
  fi > >(cat 1<>$file)
}
