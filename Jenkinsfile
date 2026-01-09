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

        stage('Build Frontend Docker Image') {
            steps {
                dir('frontend') {
                    sh '''
                    docker build -t $FRONTEND_IMAGE:latest .
                    '''
                }
            }
        }

        stage('Build Backend Docker Image') {
            steps {
                sh '''
                docker build \
                  -f Dockerfile \
                  -t $BACKEND_IMAGE:latest \
                  .
                '''
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                sh '''
                docker push $FRONTEND_IMAGE:latest
                docker push $BACKEND_IMAGE:latest
                '''
            }
        }

        stage('Run Containers') {
            steps {
                sh '''
                docker rm -f frontend backend || true

                docker run -d \
                  --name backend \
                   -p 5000:5000 \
                   -e NODE_ENV=development \
                -e PORT=5000 \
                   -e MONGO_URI="mongodb+srv://sandeeptiwari_db_user:vHxJba4SRSaC4tIV@cluster0.cbb1rgz.mongodb.net/?appName=Cluster0" \
                   -e JWT_SECRET="abc123" \
                    sandeeptiwari0206/mern-backend:latest


                docker run -d \
                  --name frontend \
                  -p 3000:3000 \
                  $FRONTEND_IMAGE:latest
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Jenkins pipeline completed successfully!"
        }
        failure {
            echo "❌ Jenkins pipeline failed. Check logs."
        }
    }
}
