
echo "*** This is a.sh ***"

tmp="$(find_path 'this_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'this_file':      $tmp"
tmp="$(find_path 'this' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'this':           $tmp"
tmp="$(find_path 'last_exec_file' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'last_exec_file': $tmp"
tmp="$(find_path 'last_exec' ${#BASH_SOURCE[@]} "${BASH_SOURCE[@]}")"
echo "find_path 'last_exec':      $tmp"
echo ""

echo "Sourcing b/b.sh..."
source $PROJECT_BASE_PATH/b/b.sh