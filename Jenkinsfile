pipeline {
    agent none

    environment {
        REGISTRY         = "docker.io"
        IMAGE_NAME       = "blessing67/petclinic"
        DOCKER_CLI_IMAGE = "docker:20.10.16" // Valid Docker CLI image
    }

    stages {
        stage('Prepare Workspace') {
            agent any
            steps {
                cleanWs()
                checkout([$class: 'GitSCM',
                          branches: [[name: '*/main']],
                          userRemoteConfigs: [[credentialsId: 'docker-cred',
                                               url: 'https://github.com/Mkhwanazi-B/spring-petclinic.git']]])
            }
        }

        stage('Build Jar') {
            agent {
                docker {
                    image 'maven:3.9-eclipse-temurin-17'
                    args  '-v /var/run/docker.sock:/var/run/docker.sock --user root -v /tmp:/tmp'
                }
            }
            steps {
                script {
                    sh 'chmod +x ./mvnw'
                    sh './mvnw clean package -DskipTests'
                    stash includes: 'target/*.jar', name: 'jar-artifact'
                }
            }
        }

        stage('Build Docker Image') {
            agent {
                docker {
                    image "${DOCKER_CLI_IMAGE}"
                    args  '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    unstash 'jar-artifact'
                    sh "docker build -f Dockerfile -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            agent {
                docker {
                    image "${DOCKER_CLI_IMAGE}"
                    args  '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    docker.withRegistry('', 'docker-cred') {
                        docker.image("${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }

        stage('Update Deployment Manifest') {
            agent any
            steps {
                withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                    sh """
                        git config user.email "blessing67mkhwanazi@gmail.com"
                        git config user.name "Blessing Mkhwanazi"

                        sed -i "s|image: docker.io/blessing67/petclinic:.*|image: docker.io/blessing67/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml

                        git add k8s/petclinic.yml
                        if git diff --cached --quiet; then
                            echo "No changes to commit"
                        else
                            git commit -m "🚀 Deploy petclinic:${BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/Mkhwanazi-B/spring-petclinic HEAD:main
                            echo "✅ Updated deployment manifest - ArgoCD will handle deployment"
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 CI Pipeline completed successfully!"
            echo "📦 Docker image: ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}"
            echo "🔄 ArgoCD will detect the updated manifest and deploy automatically"
        }
        failure {
            echo "❌ Pipeline failed. Check the logs above."
        }
    }
}
