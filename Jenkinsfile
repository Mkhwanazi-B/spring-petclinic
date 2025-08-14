pipeline {
  agent any

  environment {
    REGISTRY  = "docker.io"
    IMAGE_NAME = "blessing67/petclinic"
  }

  stages {
    stage('Checkout & Build Jar') {
      steps {
        script {
          cleanWs()
          checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[credentialsId: 'docker-cred',
                                         url: 'https://github.com/Mkhwanazi-B/spring-petclinic.git']]])
          
          // Use Docker to run Maven
          sh '''
            docker run --rm \
              -v $(pwd):/workspace \
              -v /var/run/docker.sock:/var/run/docker.sock \
              -w /workspace \
              maven:3.9-eclipse-temurin-17 \
              mvn clean package -DskipTests
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          sh "docker build -f Dockerfile -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} ."
        }
      }
    }

    stage('Push Docker Image') {
      steps {
        script {
          docker.withRegistry('', 'docker-cred') {
            docker.image("${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER}").push()
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
          sh "kubectl apply -f k8s/db.yml"
          sh "kubectl apply -f k8s/petclinic.yml"
        }
      }
    }

    stage('GitOps Commit') {
      steps {
        withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
          sh """
            git config user.email "blessing67mkhwanazi@gmail.com"
            git config user.name "Blessing Mkhwanazi"

            sed -i "s|image: docker.io/blessing67/petclinic:.*|image: docker.io/blessing67/petclinic:${BUILD_NUMBER}|g" k8s/petclinic.yml

            git add k8s/petclinic.yml
            git diff --cached --quiet || git commit -m "Update petclinic image tag to ${BUILD_NUMBER}"
            git push https://${GITHUB_TOKEN}@github.com/Mkhwanazi-B/spring-petclinic HEAD:main
          """
        }
      }
    }
  }
}