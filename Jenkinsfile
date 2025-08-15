pipeline {
    agent none

    environment {
        REGISTRY         = "docker.io"
        IMAGE_NAME       = "blessing67/petclinic"
        DOCKER_CLI_IMAGE = "docker:20.10.16"
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

        stage('Build & Push Docker Image') {
            agent {
                docker {
                    image "${DOCKER_CLI_IMAGE}"
                    args  '-v /var/run/docker.sock:/var/run/docker.sock --user root'
                }
            }
            steps {
                script {
                    sh "docker build -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} ."
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
