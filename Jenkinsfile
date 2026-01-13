pipeline {
    agent { label 'ec2-node' }

    environment {
        IMAGE_TAG      = "${BUILD_NUMBER}"
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

        stage('SonarQube Analysis - Frontend') {
            steps {
                dir('frontend') {
                    withSonarQubeEnv('sonarqube') {
                        sh 'sonar-scanner'
                    }
                }
            }
        }

        stage('SonarQube Analysis - Backend') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Build & Push Images') {
            steps {
                dir('frontend') {
                    sh "docker build -t $FRONTEND_IMAGE:$IMAGE_TAG ."
                    sh "docker push $FRONTEND_IMAGE:$IMAGE_TAG"
                }

                sh "docker build -t $BACKEND_IMAGE:$IMAGE_TAG ."
                sh "docker push $BACKEND_IMAGE:$IMAGE_TAG"
            }
        }

        stage('Deploy Containers on EC2') {
            environment {
                MONGO_URI  = credentials('mongo-uri')
                JWT_SECRET = credentials('jwt-secret')
            }
            steps {
                sh '''
                docker pull $FRONTEND_IMAGE:$IMAGE_TAG
                docker pull $BACKEND_IMAGE:$IMAGE_TAG

                docker rm -f frontend backend || true

                docker run -d --name backend -p 5000:5000 \
                  -e NODE_ENV=production \
                  -e PORT=5000 \
                  -e MONGO_URI=$MONGO_URI \
                  -e JWT_SECRET=$JWT_SECRET \
                  $BACKEND_IMAGE:$IMAGE_TAG

                docker run -d --name frontend -p 3000:3000 \
                  $FRONTEND_IMAGE:$IMAGE_TAG
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD completed successfully on EC2 Jenkins Agent"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins & SonarQube logs."
        }
    }
}
