#!/bin/bash

source ./common.sh

check_root

dnf module disable redis -y &>>$LOG_FILE
validate $? "Disabling redis.."

dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "Enabling redis version 7.."

dnf install redis -y &>>$LOG_FILE
validate $? "Installing redis.."

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
validate $? "Updating global IP  and Protect mode for redis.."

systemctl enable redis &>>$LOG_FILE
validate $? "Enabling redis service.."
systemctl start redis 
validate $? "Starting redis service.."
print_total_time