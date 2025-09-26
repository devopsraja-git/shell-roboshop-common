#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>>$LOG_FILE
validate $? "Installing mysql server.."

systemctl enable mysqld &>>$LOG_FILE
validate $? "Enable mysql service.."
systemctl start mysqld  &>>$LOG_FILE
validate $? "Start mysql service.."

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
validate $? "Setting up Root password"

print_total_time