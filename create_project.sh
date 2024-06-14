#!/bin/bash

# Создаем директорию проекта
mkdir -p my-go-app

# Переходим в директорию проекта
cd my-go-app

# Создаем файл docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    container_name: my-go-app
    ports:
      - "8080:8080"
    command: ["/app/my-go-app"]
EOF

# Создаем файл Dockerfile
cat <<EOF > Dockerfile
FROM golang:1.19 AS builder

WORKDIR /app

COPY . .

RUN go mod init my-go-app
RUN go mod tidy
RUN go build -o my-go-app

FROM golang:1.19

WORKDIR /app

COPY --from=builder /app/my-go-app /app/my-go-app

CMD ["./my-go-app"]
EOF

# Создаем файл Jenkinsfile
cat <<EOF > Jenkinsfile
pipeline {
    agent {
        docker {
            image 'golang:1.19'
            args '-v $PWD:/app'
        }
    }

    stages {
        stage('Build and Test') {
            steps {
                script {
                    sh 'cd /app && go build -o my-go-app && go test ./...'
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
EOF

# Создаем файл main.go
cat <<EOF > main.go
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "Hello, World!")
    })

    fmt.Println("Starting server on :8080")
    if err := http.ListenAndServe(":8080", nil); err != nil {
        fmt.Println("Failed to start server:", err)
    }
}

func Add(a, b int) int {
    return a + b
}
EOF

# Создаем файл main_test.go
cat <<EOF > main_test.go
package main

import "testing"

func TestAdd(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("Add(2, 3) = %d; want 5", result)
    }
}
EOF

# Создаем файл docker-compose-jenkins.yml
cat <<EOF > docker-compose-jenkins.yml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8081:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false

volumes:
  jenkins_home:
EOF

echo "Проект my-go-app создан успешно!"

# Сборка и запуск Docker Compose для приложения
docker-compose up --build -d

# Сборка и запуск Docker Compose для Jenkins
docker-compose -f docker-compose-jenkins.yml up -d

# Проверка состояния контейнеров
docker-compose ps
docker-compose -f docker-compose-jenkins.yml ps

# Проверка логов контейнера приложения
docker-compose logs app

# Проверка логов контейнера Jenkins
docker-compose -f docker-compose-jenkins.yml logs jenkins

# Инструкция по доступу к Jenkins
echo "Для доступа к Jenkins откройте http://localhost:8081"
echo "Для разблокировки Jenkins найдите пароль в логах контейнера Jenkins:"
docker-compose -f docker-compose-jenkins.yml logs jenkins | grep "Please use the following password"
