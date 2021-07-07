#!/bin/bash
# This script checks if the tenant if newer than an exiting one.
# Every time that the user calls mc, the for loop checks to see if any vault secrets are newer than the most recent lockfile. 
# If the secret is newer, then it reinitializes the client right away.

# Pointer to the real mc CLI
MC=/usr/local/bin/mc-original

for  f in $(ls /vault/secrets/minio-* | grep -v -E '\..*'); do
 tenant=$(basename "$f" | sed 's/^minio-//') # remove minio- prefix 
 if [ ! -f /tmp/.minio-$tenant ] || [ $f -nt /tmp/.minio-$tenant ]; then
     (
         source $f
         $MC config host add $tenant $MINIO_URL $MINIO_ACCESS_KEY $MINIO_SECRET_KEY
     )
     touch /tmp/.minio-$tenant
 fi
done
args=( "$@" )
for ((i=0; i < $#; i++)) ;do
  if [  "${args[$i]}" != "${args[$i]% *}" ]; then
    args[$i]="\"${args[$i]}\""
  fi
done
set "${args[@]}"
$MC "$@"