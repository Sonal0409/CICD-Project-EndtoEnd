pipeline{
    agent any
    tools{
        maven 'mymaven'
    }
    stages{
        stage('Checkout the Code')
        {
            steps{
                git 'https://github.com/Sonal0409/DevOpsCodeDemo.git'
            }
        }
        stage('Test Code')
        {
            steps{
                sh 'mvn test'
            }
        }

        stage('Build Code')
        {
            steps{
                sh 'mvn package'
            }
        }
// add a stage to build docker image    
          stage('Build Docker Image') {
            steps{
            // execute the chmod command on the terminal to allow jenkins to run docker commands
            // sh 'chmod 777 /var/run/docker.sock'
                sh 'docker build -t myprojectimage:latest .'
            }
            }
// stage to login to dockerhub using plugin withCredentials
        stage('Continous Delivery - Docker push Image') {
            steps{
                // login via terminal using docker login command
                sh 'docker tag myprojectimage:latest sonal0409/myprojectimage:latest'
                sh 'docker push sonal0409/myprojectimage:latest'
                }
            }
        }


    }

