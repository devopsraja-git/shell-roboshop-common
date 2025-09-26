#!/bin/bash

source ./common.sh

app_name=catalogue

check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Creating mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? "Installing mongodb client.."


INDEX=$(mongosh mongodb.devraxtech.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
    if [ $INDEX -le 0 ]; then
        mongosh --host $MONGODB_HOST < /app/db/master-data.js &>>$LOG_FILE
        validate $? "Loading mongodb data ..."
    else
        echo -e "Catalogue products already loaded...$Y SKIPPING... $N"
    fi

app_restart
print_total_time



