pipeline {
    agent {
        label 'mikrus'
    }
    environment {
        forcePrune = false
        version = "${sh( returnStdout: true, script: '''grep version Dockerfile | cut -d'\"' -f2 | sed -e \"s/\\\r?\\\n//\" ''')} "
        requiresBuilding = true
    }
    stages {
        stage('Check if latest image is built') {
            steps {
                echo 'Checking latest version'
                sh '''
                for tag in $(docker images netpass_builder | sed -Ee 's/ +/ /gm' | cut -d" " -f 2 | tail -n +2)
                do
                    if [ "$tag" == "${version}" ]; then
                        requiresBuilding = false
                        break
                    fi
                done
                '''
                echo "Version: ${version}"
                echo "Requires Building: ${requiresBuilding}"
            }
        }
        stage('Build docker image') {
            when { expression { return requiresBuilding } }
            steps {
                sh 'docker build -t netpass_builder:${version} -f ./Dockerfile ./'
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}