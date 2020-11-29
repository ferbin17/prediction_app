#! /bin/bash

# create log file for cron if needed 
CRON_FILE=~/data/prediction_app/log/prediction_app_cron.log
if test -f "$CRON_FILE"; then
   :
else
   touch $CRON_FILE
fi

# create log file for script if needed
FILE=~/data/prediction_app/log/prediction_app.log
if test -f "$FILE"; then
   :
else
   touch $FILE
fi
