pipeline {
    agent any

    stages {
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

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: 'my-go-app', allowEmptyArchive: true
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
