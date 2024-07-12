#!/bin/bash

ID=$(id -u)
R="/e[31m"
G="/e[32m"
Y="/e[33m"
N="/e[0m"
MONGDB_HOST=blank_for_now

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo -e "Script started at ... $Y $TIMESTAMP $N" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R Fail $N"
    else
        echo -e "$2 ... $G Success $N"
    fi
}

# Check if user is root
if [ $ID -ne 0 ]; then
    echo -e "$R Please run as root $N"
else
    echo "You are a $G Root User $N"
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $?  "Disabling nodejs module"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs module"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs"

id roboshop
if [ $1 -ne 0 ]; then
    user add roboshop
    VALIDATE $? "Adding roboshop user" &>> $LOGFILE
else
    echo -e "roboshop user already created ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "Downloading catalogue.zip"

cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue.zip"

npm install &>> $LOGFILE
VALIDATE $? "Installing npm packages"

cp home/centos/roboshop-shell/catalogue.service /etc/sustemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue.service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading systemctl daemon"

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "Starting catalogue service"

cp home/centos/roboshop-shell/mongo.rep /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org-shell &>> $LOGFILE
VALIDATE $? "Installing mongodb-org-shell"

mongo --host $MONGDB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? "Loading catalogue schema"
