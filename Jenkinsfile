   pipeline {
       agent any

       stages {
           stage('Checkout') {
               steps {
                   script {
                       git url: 'https://github.com/musikfed/my-go-app.git', credentialsId: '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'
                   }
               }
           }

           stage('Build') {
               steps {
                   script {
                       docker.image('golang:1.19').inside {
                           sh 'go build -o my-go-app'
                       }
                   }
               }
           }

           stage('Test') {
               steps {
                   script {
                       docker.image('golang:1.19').inside {
                           sh 'go test ./...'
                       }
                   }
               }
           }

           stage('Build Docker Image') {
               steps {
                   script {
                       sh 'docker build -t my-go-app:latest .'
                   }
               }
           }

           stage('Deploy') {
               steps {
                   script {
                       sh 'docker-compose down'
                       sh 'docker-compose up --build -d'
                   }
               }
           }
       }
   }
