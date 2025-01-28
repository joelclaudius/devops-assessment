#!/bin/bash -x

#### Autor : Claudius
#### Date : 28-01-2025

sudo yum update -y

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

sudo yum upgrade -y

## install And Enable Docker
sudo yum install docker -y
sudo yum install -y docker.io
sudo service docker start 
sudo systemctl enable docker.service

sudo chmod 777  /var/run/docker.sock


## install Git
sudo yum install git -y
yum install unzip -y

## Install Java 17:
sudo amazon-linux-extras enable corretto17
sudo yum install java-17-amazon-corretto -y

## Install Jenkins then Enable the Jenkins service to start at boot :
sudo yum install jenkins -y
sudo systemctl enable jenkins

## Start Jenkins as a service:
sudo systemctl start jenkins

## Display Initial Jenkins Password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword