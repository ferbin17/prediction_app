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

# Update code
cd ~/data/prediction_app/ && git checkout main && git pull

#call rake task
~/.rvm/wrappers/ruby-2.7.2@emset-name/bundle install
RAILS_ENV=production ~/.rvm/wrappers/ruby-2.7.2@gemset-name/rake assets:clobber
RAILS_ENV=production ~/.rvm/wrappers/ruby-2.7.2@emset-name/rake assets:precompile
RAILS_ENV=production ~/.rvm/wrappers/ruby-2.7.2@emset-name/rake db:migrate
RAILS_ENV=production ~/.rvm/wrappers/ruby-2.7.2@emset-name/rake db:seed
sudo /usr/bin/systemctl restart prediction_app.service
sudo /usr/bin/systemctl restart predict_app_sidekiq.service
