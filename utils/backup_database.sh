#!/bin/bash


case "$1" in
    testdb1)
        DB_NAME='testdb1'
        SWIFT_CONTAINER='testdb1'
        ;;
    lunr)
        DB_NAME='testdb2'
        SWIFT_CONTAINER='testdb2'
        ;;
    *)
        echo "usage: $0 [testdb1|testdb2]"
        exit 1
esac

RETRIES="5"

DEBUG="no"
ENV="DEV"
SWIFTLY_AUTH_URL="https://rackspaceauthrul/auth/v2.0"
SWIFTLY_AUTH_USER="swiftuser"
SWIFTLY_AUTH_KEY="authkey"

# Nothing below here should need to be edited.

export SWIFTLY_AUTH_KEY SWIFTLY_AUTH_USER SWIFTLY_AUTH_URL
SWIFTLY=$(which swiftly)
DB_HOST='localhost'
BACKUPFILE="${DB_NAME}_${ENV}-$(date +%Y%m%d).sql.gz"
BACKUPPATH="/tmp/${BACKUPFILE}"
LOGFILE="/tmp/backups-swiftlylog-${ENV}-${DB_NAME}.log"

# Put you pg backup code line here.  
pg_dump ${DB_NAME} | gzip -9 > ${BACKUPPATH}

for (( ATTEMPT=1; ATTEMPT<$((${RETRIES}+1)); ATTEMPT++ )); do
    ${SWIFTLY} put --input=${BACKUPPATH} ${SWIFT_CONTAINER}/${BACKUPFILE} > ${LOGFILE} 2>&1
    if [ $? -eq 0 ]; then
        if [ "${DEBUG}" = "yes" ]; then
            echo "Upload of ${BACKUPPATH} to swift (${ENV}) succeeded on attempt ${ATTEMPT} at $(date)."
        fi
        rm -f ${BACKUPPATH} ${LOGFILE}
        break
    else
        echo "Upload of ${BACKUPPATH} to swift (${ENV}) failed on attempt ${ATTEMPT} at $(date)."
        echo "-- Begin Swiftly output --"
        cat ${LOGFILE}
        echo "-- End Swiftly output --"
        if [ "${ATTEMPT}" -lt "${RETRIES}" ]; then
            let SLEEPS=$((${ATTEMPT} ** ${ATTEMPT}))
            echo "Sleeping for ${SLEEPS} seconds."
            sleep ${SLEEPS}
        else
            echo "Stopped trying. Backup file remains at ${BACKUPPATH}"
            exit 1
        fi
    fi
done

