[[ -n $GUARD_HANDLE_ARGS ]] && return || readonly GUARD_HANDLE_ARGS=1

_handle_args()
{
    while [ "${1:-}" != "" ]; do
        # NOT optional: neither single dash or double dash
        if ! [[ "${1:0:1}" == "-" ]] && ! [ "${1:0:2}" == "--" ]; then
            non_optional_args+=("${1}")
        else
        # Optional: single dash or double dash
            case "$1" in
            '-u'|'--user'|'--username')
                shift
                user_arg="$1"
                ;;
            '-p'|'--pass'|'--password')
                shift
                password_arg="$1"
                ;;
            '-i'|'--ip')
                shift
                ip_arg="$1"
                ;;
            '-o'|'--out'|'--output')
                shift
                output_arg="$1"
                ;;
            '--output-path')
                shift
                output_path_arg="$1"
                echo "output_path_arg: $output_path_arg"
                ;;
            '-l'|'--log-path')
                shift
                log_path_arg="$1"
                ;;
            '--daemon')
                daemon_arg='true'
                ;;
            '--kill-daemon') # TODO: Should not need "non-optional" argument
                kill_daemon_arg='true'
                shift
                kill_daemon_arg_value="$1"
                ;;
            '--script-output')
                shift
                script_output_arg="$1"
                ;;
            *)
                # Did not find optional, treat as non-optional.
                non_optional_args+=("${1}")
                ;;
            esac
        fi
        shift
    done
}
