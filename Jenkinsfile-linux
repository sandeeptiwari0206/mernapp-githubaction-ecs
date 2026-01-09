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
                    sh 'docker build -t $FRONTEND_IMAGE:latest .'
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                dir('backend') {
                    sh 'docker build -t $BACKEND_IMAGE:latest .'
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
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Push Images') {
            steps {
                sh '''
                  docker push $FRONTEND_IMAGE:latest
                  docker push $BACKEND_IMAGE:latest
                '''
            }
        }

        stage('Deploy Containers') {
            steps {
                withCredentials([
                    string(credentialsId: 'mongo-uri', variable: 'MONGO_URI'),
                    string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
                ]) {
                    sh '''
                    docker rm -f frontend backend || true

                    docker run -d \
                      --name backend \
                      -p 5000:5000 \
                      -e NODE_ENV=development \
                      -e PORT=5000 \
                      -e MONGO_URI="$MONGO_URI" \
                      -e JWT_SECRET="$JWT_SECRET" \
                      $BACKEND_IMAGE:latest

                    docker run -d \
                      --name frontend \
                      -p 3000:3000 \
                      $FRONTEND_IMAGE:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ MERN pipeline deployed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins logs."
        }
    }
}
