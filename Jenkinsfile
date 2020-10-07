pipeline {
  agent {
    label 'agent1'
  }
  environment {
    TIMEOUT = "30"
  }
  options {
    timeout(time: 4, unit: 'HOURS')
    buildDiscarder(logRotator(numToKeepStr: '100'))
    ansiColor('xterm')
  }
  stages {
    stage('Setup') {
      steps {
        script {
          defaultParams = [
            releaseBranch: /master/,
            release_repo: 'xen-release',
            release_script: 'make release',
          ]
          config = defaultParams << params
        }
      }
    }
      
    stage('Build') {
      when {
        expression { BRANCH_NAME ==~ config.releaseBranch }
      }
      steps {
        sh 'make release'
      }
    }
      
    stage('Publish') {
      when {
        expression { BRANCH_NAME ==~ config.releaseBranch }
      }
      steps {
        rtServer (
          id: 'xen-artifactory',
          url: 'https://xenstack.jfrog.io/artifactory',
          credentialsId: '292ed262-ca33-427f-a6f1-304f8574882b',
          timeout: 300
        )
        rtUpload (
          serverId: 'xen-artifactory',
          spec: '''{
            "files": [
              {
                "pattern": "*.rpm",
                "target": config.release_repo,
              }
            ]
          }'''
        )
      }
    }  
  }
  post {
    always {
      cleanWs()
    }
  }
}
