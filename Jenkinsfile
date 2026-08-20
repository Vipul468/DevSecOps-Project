// ============================================================================
// DevOps Project-2  ·  Amazon Prime Clone  ·  Fully-automated CI/CD
// Flow: checkout -> SonarQube -> npm build -> Trivy FS -> Docker build
//       -> Trivy image -> push to ECR -> bump k8s manifest -> Argo CD syncs
// ----------------------------------------------------------------------------
// Prereqchecklist on the Jenkins node (see scripts/install-tools.sh):
//   docker, awscli v2, trivy, sonar-scanner, node18, git
// Jenkins plugins: Docker Pipeline, SonarQube Scanner, Pipeline: AWS Steps,
//   Credentials Binding, NodeJS
// Jenkins credentials to create (Manage Jenkins > Credentials):
//   - aws-creds        : AWS access key/secret (or use an EC2 instance role)
//   - sonar-token      : SonarQube token (Secret text)         -> id: sonar-token
//   - tmdb-api-key     : TMDB v3 API key (Secret text)         -> id: tmdb-api-key
//   - github-creds     : GitHub PAT for pushing manifest bump  -> id: github-creds
// Configure a SonarQube server named "SonarQube" in Manage Jenkins > System.
// ============================================================================
pipeline {
  agent any

  environment {
    AWS_REGION   = 'us-east-1'
    ACCOUNT_ID   = '123456789012'                 // <-- change to your AWS account id
    ECR_REPO     = 'prime-clone'
    ECR_REGISTRY = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    IMAGE_TAG    = "${BUILD_NUMBER}"
    IMAGE        = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
    GIT_REPO     = 'github.com/your-github-org/devops-project2.git'  // manifest repo
  }

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('SonarQube - Code Quality') {
      steps {
        withSonarQubeEnv('SonarQube') {
          sh '''
            sonar-scanner \
              -Dsonar.projectKey=prime-clone \
              -Dsonar.sources=app/src \
              -Dsonar.host.url=$SONAR_HOST_URL \
              -Dsonar.login=$SONAR_AUTH_TOKEN
          '''
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

    stage('npm Install & Build') {
      steps {
        dir('app') {
          sh '''
            npm ci
            npm run build
          '''
        }
      }
    }

    stage('Trivy - Filesystem/Dependency Scan') {
      steps {
        sh 'trivy fs --severity HIGH,CRITICAL --exit-code 0 --no-progress app > trivy-fs-report.txt || true'
        archiveArtifacts artifacts: 'trivy-fs-report.txt', onlyIfSuccessful: false
      }
    }

    stage('Docker Build') {
      steps {
        withCredentials([string(credentialsId: 'tmdb-api-key', variable: 'TMDB_KEY')]) {
          sh 'docker build --build-arg TMDB_V3_API_KEY=$TMDB_KEY -t $IMAGE app'
        }
      }
    }

    stage('Trivy - Image Scan (gate)') {
      steps {
        // fail the build on CRITICAL/HIGH fixable vulns
        sh 'trivy image --severity CRITICAL,HIGH --ignore-unfixed --exit-code 1 --no-progress $IMAGE'
      }
    }

    stage('Push to AWS ECR') {
      steps {
        withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
          sh '''
            aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION \
              || aws ecr create-repository --repository-name $ECR_REPO --region $AWS_REGION \
                   --image-scanning-configuration scanOnPush=true
            aws ecr get-login-password --region $AWS_REGION \
              | docker login --username AWS --password-stdin $ECR_REGISTRY
            docker push $IMAGE
          '''
        }
      }
    }

    stage('Update K8s Manifest (GitOps)') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-creds',
                          usernameVariable: 'GIT_USER', passwordVariable: 'GIT_TOKEN')]) {
          sh '''
            sed -i "s|image: .*prime-clone:.*|image: ${IMAGE}|" kubernetes/deployment.yaml
            git config user.email "ci@jenkins"
            git config user.name  "jenkins-ci"
            git add kubernetes/deployment.yaml
            git commit -m "ci: deploy prime-clone build ${IMAGE_TAG}" || echo "no change"
            git push https://${GIT_USER}:${GIT_TOKEN}@${GIT_REPO} HEAD:main
          '''
        }
      }
    }
  }

  post {
    always  { sh 'docker image prune -f || true' }
    success { echo "✅ Build ${IMAGE_TAG} pushed. Argo CD will sync it to EKS." }
    failure { echo "❌ Pipeline failed at stage — check the console log above." }
  }
}
