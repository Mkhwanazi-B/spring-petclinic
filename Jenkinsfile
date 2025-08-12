pipeline {
  agent none

  environment {
    REGISTRY = "docker.io"
    IMAGE_NAME = "blessing67/petclinic"
  }

  stages {
    stage('Checkout & Build Jar') {
      agent {
        docker {
          image 'blessing67/my-maven-docker-agent:latest'
          args '-v /var/run/docker.sock:/var/run/docker.sock --user root --entrypoint=""'
        }
      }
      steps {
        script {
          cleanWs()
          git branch: 'main', credentialsId: 'github', url: 'https://github.com/Mkhwanazi-B/spring-petclinic'
          sh './mvnw clean package -DskipTests'
        }
      }
    }

    stage('Build Docker Image') {
      agent {
        docker {
          image 'docker:20.10.16'
          args '-v /var/run/docker.sock:/var/run/docker.sock --user root'
        }
      }
      steps {
        script {
          sh "docker build -f Dockerfile -t ${REGISTRY}/${IMAGE_NAME}:${BUILD_NUMBER} ."
        }
      }
    }

    stage('Push Docker Image') {
      agent {
        docker {
          image 'docker:20.10.16'
          args '-v /var/run/docker.sock:/var/run/docker.sock --user root'
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

    stage('Deploy to Kubernetes') {
      agent any
      steps {
        withKubeConfig([credentialsId: 'kubeconfig-credentials']) {
          sh "kubectl apply -f k8s/db.yml"
          sh "kubectl apply -f k8s/petclinic.yml"
        }
      }
    }

    stage('GitOps Commit') {
      agent any
      steps {
        withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
          script {
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
}