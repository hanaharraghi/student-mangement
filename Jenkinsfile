pipeline {
    agent any
    triggers {
        githubPush()
    }
    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Récupération du code depuis GitHub...'
                git branch: 'main', url: 'https://github.com/sahlihamza/DevOps_Project.git'
            }
        }
        stage('Build') {
            steps {
                echo 'Compilation du projet...'
                sh 'mvn clean compile'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de la qualité du code...'
                sh '''
                    mvn sonar:sonar \
                    -Dsonar.projectKey=student-management \
                    -Dsonar.projectName="Student Management" \
                    -Dsonar.host.url=http://localhost:9000 \
                    -Dsonar.token=${SONAR_TOKEN}
                '''
                echo 'Analyse envoyée à SonarQube - Consultez http://localhost:9000/dashboard?id=student-management'
            }
        }
        stage('Package') {
            steps {
                echo 'Création du JAR...'
                sh 'mvn package -DskipTests'
            }
        }
        stage('Build Docker Image') {
            steps {
                echo 'Construction de l\'image Docker...'
                sh 'docker build -t student-management:latest .'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Déploiement du conteneur...'
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
            echo 'Pipeline réussi avec succès'
        }
        failure {
            echo 'Pipeline échoué - Vérifiez les logs'
        }
    }
}
