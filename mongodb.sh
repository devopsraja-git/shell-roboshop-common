#!/bin/bash

source ./common.sh

check_root

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Adding mongo repo"

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "Installing mongodb"

systemctl enable mongod &>>$LOG_FILE
validate $? "Enable MongoDB"

systemctl start mongod
validate $? "Starting.. MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
validate $? "Update mongodb IP address"

systemctl restart mongod
validate $? "Restarting mongodb service"

print_total_time