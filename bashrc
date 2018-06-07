export EDITOR=vim

#alias ll='ls -l'
#alias la='ls -la'
alias lf='ls -F'

# alias ..="cd .."
# alias ...="cd ../.."
# alias ....="cd ../../.."
# alias .....="cd ../../../.."
# alias ......="cd ../../../../.."
# alias .......="cd ../../../../../.."
# alias ........="cd ../../../../../../.."
# alias .........="cd ../../../../../../../.."
# alias ..........="cd ../../../../../../../../.."

alias vf='sh -c "vim \$(find -iname \"*\$0*.\$1*\") "'

function mkdirc {
        mkdir $1
        cd $1
}

# Upload file on change
# $1 - file to upload
# $2 - SCP URL of the target directory/file
function upload_on_change {
    if [[ "$1" == "" || "$2" == "" ]] ; then
        echo "Usage: $0 {file-to-monitor} {scp-url--target-dir}"
        return 1
    fi

    FILE_TO_MONITOR="$1"
    UPLOAD_URL="$2"
    CHECK_SLEEP=1

    echo "Upload '$FILE_TO_MONITOR' to '$UPLOAD_URL' on change..."
    echo "Checking every ${CHECK_SLEEP}s"

    OLD_HASH=""
    OLD_MODIFY=""
    while true ; do
        MODIFY="$(stat -c %y "$FILE_TO_MONITOR" 2> /dev/null)" || MODIFY="$OLD_MODIFY"
        if [[ "$OLD_MODIFY" == "$MODIFY" ]] ; then
            sleep $CHECK_SLEEP
            continue
        fi
        OLD_MODIFY="$MODIFY"
        HASH="$(md5sum "$FILE_TO_MONITOR")"
        if [[ "$OLD_HASH" == "$HASH" ]] ; then
            sleep $CHECK_SLEEP
            continue
        fi

        NEW_HASH=""
        while sleep 1 ; do
            if [[ -f "$FILE_TO_MONITOR" ]] ; then
                NEW_HASH="$(md5sum "$FILE_TO_MONITOR")"
                if [[ "$NEW_HASH" == "$HASH" ]] ; then
                    break
                fi
                HASH="$NEW_HASH"
            else
                NEW_HASH=""
                break
            fi
        done
        if [[ "$NEW_HASH" != "" && "$OLD_HASH" != "$NEW_HASH" ]] ; then
            echo "$(date "+%F %T") Uploading $FILE_TO_MONITOR to $UPLOAD_URL"
            scp "$FILE_TO_MONITOR" "$UPLOAD_URL"
            which cmd.exe > /dev/null 2>&1 && cmd '/c rundll32.exe cmdext.dll,MessageBeepStub '
            #which cmd.exe > /dev/null 2>&1 && cmd '/c rundll32 user32.dll,MessageBeep '
            OLD_HASH="$NEW_HASH"
        fi
        sleep $CHECK_SLEEP
    done
}

function ps-mem {
    ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=2 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }' |cut -d "" -f2 | cut -d "-" -f1 | less
}

# vim: set ts=4 sts=4 sw=4 expandtab:
