pipeline {
    agent any

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
                        script {
                            def scannerHome = tool 'SonarScanner'
                            bat "${scannerHome}\\bin\\sonar-scanner.bat"
                        }
                    }
                }
            }
        }

        stage('SonarQube Analysis - Backend') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    script {
                        def scannerHome = tool 'SonarScanner'
                        bat "${scannerHome}\\bin\\sonar-scanner.bat"
                    }
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

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    bat """
                    docker build ^
                      -t %FRONTEND_IMAGE%:%IMAGE_TAG% ^
                      -t %FRONTEND_IMAGE%:latest .
                    """
                }
            }
        }

        stage('Build Backend Image') {
            steps {
                bat """
                docker build ^
                  -t %BACKEND_IMAGE%:%IMAGE_TAG% ^
                  -t %BACKEND_IMAGE%:latest .
                """
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
                docker push %FRONTEND_IMAGE%:%IMAGE_TAG%
                docker push %FRONTEND_IMAGE%:latest

                docker push %BACKEND_IMAGE%:%IMAGE_TAG%
                docker push %BACKEND_IMAGE%:latest
                """
            }
        }

        stage('Deploy on Linux EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    ),
                    string(credentialsId: 'mongo-uri', variable: 'MONGO_URI'),
                    string(credentialsId: 'jwt-secret', variable: 'JWT_SECRET')
                ]) {
                    bat """
                    ssh -i %SSH_KEY% -o StrictHostKeyChecking=no %SSH_USER%@EC2_PUBLIC_IP ^
                    "docker pull %FRONTEND_IMAGE%:%IMAGE_TAG% && ^
                     docker pull %BACKEND_IMAGE%:%IMAGE_TAG% && ^
                     docker rm -f frontend backend || true && ^
                     docker run -d --name backend -p 5000:5000 ^
                        -e NODE_ENV=production ^
                        -e PORT=5000 ^
                        -e MONGO_URI=%MONGO_URI% ^
                        -e JWT_SECRET=%JWT_SECRET% ^
                        %BACKEND_IMAGE%:%IMAGE_TAG% && ^
                     docker run -d --name frontend -p 3000:3000 ^
                        %FRONTEND_IMAGE%:%IMAGE_TAG%"
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD completed successfully. App deployed on Linux EC2!"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins or SonarQube logs."
        }
    }
}
