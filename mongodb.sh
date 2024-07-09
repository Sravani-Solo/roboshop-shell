#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="\tmp\$0-$TIMESTAMP.log"

echo -e "Script started at $Y $TIMESTAMP $N" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R Failed $N"
        exit 1
    else
        echo -e "$2 ... $G Success $N"
    fi
}

if [ $? -ne 0 ]
then
    echo -e "$R ERROR: Run this script with root user $N"
    exit 1
else
    echo -e "$Y You are a root user $N"
fi  

cp mongo.rep /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copy mongo.repo"

if rpm -q mongodb-org
then
    echo -e "MongoDB already Installed ... $Y SKIPPING $N"
    exit 1
else
    echo -e "$Y Installing MongoDB ... $N"
    dnf install mongodb-org -y
    VALIDATE $? "Installing MongoDB" &>> $LOGFILE
fi

systemctl enable mongod
VALIDATE $? "Enabling MongoDB" &>> $LOGFILE
systemctl start mongod
VALIDATE $? "Starting MongoDB" &>> $LOGFILE
sed -i '127.01.0/0.0.0.0/g' /etc/mongod.config &>> $LOGFILE
VALIDATE $? "Allowing MongoDB to listen on all interfaces" &>> $LOGFILE
systemctl restart mongod
VALIDATE $? "Restarting MongoDB" &>> $LOGFILE
    
