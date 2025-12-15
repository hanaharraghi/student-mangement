pipeline {
    agent any
    triggers {
        githubPush()
    }
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        DOCKER_IMAGE = 'hanaharraghi/student-management'
        BUILD_TAG = "${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Clonage du code...'
                git branch: 'main', url: 'https://github.com/hanaharraghi/student-mangement.git'
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
                echo '🐳 Construction de l\'image Docker...'
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${BUILD_TAG} ${DOCKER_IMAGE}:latest"
            }
        }
        stage('DockerHub Login & Push') {
            steps {
                echo '🔐 Connexion et push vers DockerHub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                    sh "docker push ${DOCKER_IMAGE}:${BUILD_TAG}"
                    sh "docker push ${DOCKER_IMAGE}:latest"
                }
            }
        }
        stage('Deploy to Docker (Local Test)') {
            steps {
                echo '🧪 Déploiement conteneur Docker local...'
                sh '''
                    docker stop student-app || true
                    docker rm student-app || true
                    docker run -d --name student-app -p 8081:8089 student-management:latest
                '''
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                echo '☸️ Déploiement sur Kubernetes...'
                script {
                    // Appliquer les fichiers de déploiement
                    sh 'kubectl apply -f spring-deployment.yaml'
                    
                    // Mettre à jour l'image avec le nouveau tag
                    sh "kubectl set image deployment/spring-deployment springboot=${DOCKER_IMAGE}:${BUILD_TAG} -n devops"
                    
                    // Attendre que le rollout soit terminé
                    sh 'kubectl rollout status deployment/spring-deployment -n devops --timeout=300s'
                    
                    // Vérifier le déploiement
                    sh 'kubectl get pods -n devops'
                    sh 'kubectl get svc -n devops'
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                echo '✅ Vérification du déploiement...'
                script {
                    // Attendre que les pods soient prêts
                    sh 'kubectl wait --for=condition=ready pod -l app=springboot -n devops --timeout=300s'
                    
                    // Afficher les informations de déploiement
                    sh '''
                        echo "=== Pods Status ==="
                        kubectl get pods -n devops -l app=springboot
                        
                        echo "=== Service Info ==="
                        kubectl get svc spring-service -n devops
                        
                        echo "=== Deployment Status ==="
                        kubectl rollout history deployment/spring-deployment -n devops
                    '''
                }
            }
        }
    }
    post {
        success {
            echo '🎉 Pipeline exécuté avec succès !'
            echo '✅ Application déployée sur Kubernetes dans le namespace devops'
            echo '🌐 Accès: http://<node-ip>:30080'
        }
        failure {
            echo '❌ Pipeline échoué – Vérifie les logs !'
            sh 'kubectl get pods -n devops || true'
            sh 'kubectl describe deployment spring-deployment -n devops || true'
        }
        always {
            echo '🧹 Nettoyage...'
            sh 'docker logout || true'
        }
    }
}
