#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

uid=$(id -u)


LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +$S)
SCRIPT_DIR=$PWD # for absoulute path
MONGODB_HOST=mongodb.devraxtech.fun
MYSQL_HOST=mysql.devraxtech.fun


mkdir -p $LOGS_FOLDER
echo "Script started executed at $(date)"

check_root(){
if [ $uid -ne 0 ]; then
    echo -e "ERROR:: Please run this as a $G ROOT $N User Privileges only"
    exit 1
fi
}

validate(){
    if [ $1 -ne 0 ]; then
    echo -e "$2 is $R FAILED $N"
    exit 1
else
    echo -e "$2 is $G SUCCESSFUL $N"
fi
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOG_FILE
    validate $? "nodejs disabled"

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    validate $? "Enabled nodejs 20v"

    dnf install nodejs -y &>>$LOG_FILE
    validate $? "Installing nodejs.."

    npm install &>>$LOG_FILE
    validate $? "Installing dependencies.."
}

maven_setup(){
    dnf install maven -y &>>$LOG_FILE
    validate $? "Installing Mavencode.."

    mvn clean package &>>$LOG_FILE
    validate $? "Installing maven dependencies.."
    mv target/shipping-1.0.jar shipping.jar
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    validate $? "Installing python3.."

    pip3 install -r requirements.txt &>>$LOG_FILE
    validate $? "Installing python dependencies.."
}

app_setup(){
    id roboshop &>>$LOG_FILE
    if [ $? -ne 0 ]; then
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
        validate $? "User roboshop created"
    else
        echo -e "User roboshop already exists...$Y SKIPPING.. $N"
    fi

    mkdir -p /app
    validate $? "Creating app directory.."

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    validate $? "Downloading $app_name application.."
    cd /app 
    validate $? "Changing to app directory.."
    rm -rf /app/*
    validate $? "Remove existing $app_name application code.."
    unzip /tmp/$app_name.zip &>>$LOG_FILE
    validate $? "Unzipping/Extracting the $app_name.."
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    validate $? "Copying $app_name services.."

    systemctl daemon-reload &>>$LOG_FILE

    systemctl enable $app_name &>>$LOG_FILE
    validate $? "Enabling $app_name service.."
}

app_restart(){
    systemctl start $app_name
    validate $? "Starting $app_name service.."   
}

print_total_time(){
    END_TIME=$(date +%S)
    TOTAL_TIME=$(( END_TIME - START_TIME ))
    echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"
    }