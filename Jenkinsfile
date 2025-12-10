pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        DOCKER_CREDENTIALS = credentials('dockerhub')
        DOCKER_USER = "${DOCKER_CREDENTIALS_USR}"
        DOCKER_PASS = "${DOCKER_CREDENTIALS_PSW}"
        IMAGE_NAME = "student-management"
        DOCKERHUB_REPO = "hanaharraghi/student-management"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Récupération du code depuis GitHub..."
                git branch: 'main', url: 'https://github.com/hanaharraghi/student-mangement.git'
            }
        }

        stage('Build') {
            steps {
                echo "Compilation du projet..."
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo "Analyse du code avec SonarQube..."
                sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=student-management \
                    -Dsonar.projectName='Student Management' \
                    -Dsonar.host.url=http://localhost:9000 \
                    -Dsonar.token=${SONAR_TOKEN}
                """
            }
        }

        stage('Package JAR') {
            steps {
                echo "Packaging du JAR..."
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Construction de l'image Docker..."
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Login to Docker Hub') {
            steps {
                echo "Connexion à Docker Hub..."
                sh """
                    echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Push de l'image vers Docker Hub..."
                sh """
                    docker tag ${IMAGE_NAME}:latest ${DOCKERHUB_REPO}:latest
                    docker push ${DOCKERHUB_REPO}:latest
                """
            }
        }

        stage('Deploy') {
            steps {
                echo "Déploiement local du conteneur..."
                sh """
                    docker stop student-app || true
                    docker rm student-app || true

                    docker run -d \
                        --name student-app \
                        -p 8081:8089 \
                        ${DOCKERHUB_REPO}:latest
                """
            }
        }

    }

    post {
        success {
            echo "Pipeline exécuté avec succès 🎉"
        }
        failure {
            echo "Pipeline échoué ❌ - Vérifiez les logs"
        }
    }
}
