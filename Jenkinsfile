pipeline {
    agent none

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        FRONTEND_IMAGE = "sandeeptiwari0206/mern-frontend"
        BACKEND_IMAGE  = "sandeeptiwari0206/mern-backend"
    }

    stages {

        /* =======================
           CI STAGE (WINDOWS)
           ======================= */

        stage('CI - Checkout, Sonar, Build & Push') {
            agent { label 'windows' }

            stages {

                stage('Checkout Code') {
                    steps {
                        git branch: 'main',
                            url: 'https://github.com/sandeeptiwari0206/mernapp.git'
                    }
                }

                stage('SonarQube - Frontend') {
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

                stage('SonarQube - Backend') {
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

                stage('Docker Login') {
                    steps {
                        withCredentials([usernamePassword(
                            credentialsId: 'dockerhub-creds',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
                        }
                    }
                }

                stage('Build & Push Images') {
                    steps {
                        bat """
                        docker build -t %FRONTEND_IMAGE%:%IMAGE_TAG% frontend
                        docker build -t %BACKEND_IMAGE%:%IMAGE_TAG% .
                        docker push %FRONTEND_IMAGE%:%IMAGE_TAG%
                        docker push %BACKEND_IMAGE%:%IMAGE_TAG%
                        """
                    }
                }
            }
        }

        /* =======================
           CD STAGE (LINUX EC2)
           ======================= */

        stage('CD - Deploy Containers on EC2') {
            agent { label 'slave' } // Your Linux EC2 node with Jenkins agent installed
            environment {
                MONGO_URI = credentials('mongo-uri')
                JWT_SECRET = credentials('jwt-secret')
            }
            steps {
                dir('deploy') {
                    sh """
                    docker pull ${FRONTEND_IMAGE}:${IMAGE_TAG}
                    docker pull ${BACKEND_IMAGE}:${IMAGE_TAG}

                    docker rm -f frontend backend || true

                    docker run -d --name backend -p 5000:5000 \\
                        -e NODE_ENV=production \\
                        -e PORT=5000 \\
                        -e MONGO_URI=${MONGO_URI} \\
                        -e JWT_SECRET=${JWT_SECRET} \\
                        ${BACKEND_IMAGE}:${IMAGE_TAG}

                    docker run -d --name frontend -p 3000:3000 \\
                        ${FRONTEND_IMAGE}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD Pipeline completed successfully'
        }
        failure {
            echo '❌ CI/CD Pipeline failed'
        }
    }
}
