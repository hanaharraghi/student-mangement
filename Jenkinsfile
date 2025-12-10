pipeline {
    agent any

    tools {
        git 'git'     // Nom configuré dans Global Tool Configuration
        maven 'maven' // Si tu l'as configuré
    }

    triggers {
        githubPush()
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📥 Clonage du code...'
                git branch: 'main', url: 'https://github.com/sahlihamza/DevOps_Project.git'
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Compilation du projet...'
                sh 'mvn clean compile'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Analyse SonarQube...'
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
                echo '📦 Génération du fichier JAR...'
                sh 'mvn -DskipTests package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo '🐳 Construction de l’image Docker...'
                sh 'docker build -t student-management:latest .'
            }
        }

        stage('DockerHub Login & Push Image') {
            steps {
                echo '🔐 Connexion à DockerHub...'
                
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker tag student-management:latest $DOCKER_USER/student-management:latest
                        docker push $DOCKER_USER/student-management:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                echo '🚀 Déploiement du conteneur Docker...'
                sh '''
                    docker stop student-app || true
                    docker rm student-app || true

                    docker run -d \
                        --name student-app \
                        -p 8081:8089 \
                        student-management:latest
                '''
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Pipeline échoué – Vérifiez les logs !'
        }
    }
}
