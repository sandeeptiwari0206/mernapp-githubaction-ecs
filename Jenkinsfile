pipeline {
    agent any

    environment {
        FRONTEND_IMAGE = "sandeeptiwari0206/mern-frontend"
        BACKEND_IMAGE  = "sandeeptiwari0206/mern-backend"
        DOCKER_CREDS   = "dockerhub-creds"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sandeeptiwari0206/mernapp.git'
            }
        }

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    bat 'docker build -t %FRONTEND_IMAGE% .'
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                dir('backend') {
                    bat 'docker build -t %BACKEND_IMAGE% .'
                }
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
                }
            }
        }

        stage('Push Images') {
            steps {
                bat """
                  docker push %FRONTEND_IMAGE%
                  docker push %BACKEND_IMAGE%
                """
            }
        }

        stage('Deploy Containers') {
            steps {
                withCredentials([
                    string(credentialsId: 'mongo-uri', variable: 'MONGO_URI'),
                    string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
                ]) {
                    bat """
                    docker rm -f frontend backend || exit 0

                    docker run -d ^
                      --name backend ^
                      -p 5000:5000 ^
                      -e NODE_ENV=development ^
                      -e PORT=5000 ^
                      -e MONGO_URI=%MONGO_URI% ^
                      -e JWT_SECRET=%JWT_SECRET% ^
                      %BACKEND_IMAGE%

                    docker run -d ^
                      --name frontend ^
                      -p 3000:3000 ^
                      %FRONTEND_IMAGE%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ MERN pipeline deployed successfully on Windows Docker!"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins logs."
        }
    }
}
