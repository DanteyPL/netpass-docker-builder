pipeline {
    agent {
        label 'mikrus'
    }
    environment {
        forcePrune = false
        version = """${sh( returnStdout: true, script: "grep version Dockerfile | cut -d'\"' -f2 | tr -d '\\n' ")}"""
        requiresBuilding = ""
    }
    stages {
        stage('Check if latest image is built') {
            steps {
                echo 'Checking latest version'
                script{ env.requiresBuilding = sh( returnStdout: true, script: '''
                for tag in $(docker images netpass_builder | sed -Ee 's/ +/ /gm' | cut -d" " -f 2 | tail -n +2)
                do
                    if [ "$tag" = "${version}" ]; then
                        echo false
                        exit 0
                    fi
                    echo true
                done
                ''').trim()}
                echo "Version: ${version}"
                echo "Requires Building: ${requiresBuilding}"
            }
        }
        stage('Build docker image') {
            when { equals expected: "true", actual: env.requiresBuilding }
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