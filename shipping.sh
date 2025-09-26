#!/bin/bash

source ./common.sh
app_name=shipping

check_root

app_setup
maven_setup

systemd_setup

dnf install mysql -y &>>$LOG_FILE
validate $? "Installing mySQL.."

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        echo -e "Starting to LOAD Shipping services.. "
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
        mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
        echo -e " Shipping Services $G Loaded.. $N"
    else
        echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
    fi

app_restart

print_total_time

