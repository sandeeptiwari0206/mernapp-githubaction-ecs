pipeline {
    agent any

    environment {
        IMAGE_TAG      = "${BUILD_NUMBER}"
        FRONTEND_IMAGE = "sandeeptiwari0206/mern-frontend"
        BACKEND_IMAGE  = "sandeeptiwari0206/mern-backend"
        DOCKER_CREDS   = "dockerhub-creds"
        DOCKER_BUILDKIT = "1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/sandeeptiwari0206/mernapp.git'
            }
        }

        /* ==========================
           SONARQUBE (PARALLEL)
        =========================== */
        stage('SonarQube Analysis') {
            parallel {

                stage('Frontend Scan') {
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

                stage('Backend Scan') {
                    steps {
                        withSonarQubeEnv('sonarqube') {
                            script {
                                def scannerHome = tool 'SonarScanner'
                                bat "${scannerHome}\\bin\\sonar-scanner.bat"
                            }
                        }
                    }
                }
            }
        }

        /* ==========================
           BUILD IMAGES (PARALLEL)
        =========================== */
        stage('Build Docker Images') {
            parallel {

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
            }
        }

        /* ==========================
           DOCKER HUB LOGIN
        =========================== */
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

        /* ==========================
           PUSH IMAGES (PARALLEL)
        =========================== */
        stage('Push Images') {
            parallel {

                stage('Push Frontend') {
                    steps {
                        bat """
                        docker push %FRONTEND_IMAGE%:%IMAGE_TAG%
                        docker push %FRONTEND_IMAGE%:latest
                        """
                    }
                }

                stage('Push Backend') {
                    steps {
                        bat """
                        docker push %BACKEND_IMAGE%:%IMAGE_TAG%
                        docker push %BACKEND_IMAGE%:latest
                        """
                    }
                }
            }
        }

        /* ==========================
           QUALITY GATE
        =========================== */
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        /* ==========================
           DEPLOY
        =========================== */
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
                      %BACKEND_IMAGE%:%IMAGE_TAG%

                    docker run -d ^
                      --name frontend ^
                      -p 3000:3000 ^
                      %FRONTEND_IMAGE%:%IMAGE_TAG%
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Optimized MERN pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check Jenkins or SonarQube logs."
        }
    }
}
