#!/bin/bash
# Check who's online

SERVICE="Current_Logins"
WHO=$( who |awk {' printf "%s ", $1'} )
CHECK=$( who |wc -l)

if [ $CHECK == 0 ]
then
    STATUS="0"
elif [ ! -z $CHECK ]
then
    STATUS="1"
fi

echo "$STATUS $SERVICE count=$CHECK $CHECK Logged in: $WHO "
