pipeline {
    agent {
        label 'mikrus'
    }
    environment {
        forcePrune = false
        version = """${sh( returnStdout: true, script: "grep version Dockerfile | cut -d'\"' -f2 ").trim()}"""
        requiresBuilding = ""
    }
    stages {
        stage('Check if latest docker image is build') {
            steps {
                script {
                    requiresBuilding = """${sh(returnStdout: true, script: '''
                    echo Latest installed version: ${version}
                    for tag in $(docker images netpass_builder | sed -Ee 's/ +/ /gm' | cut -d" " -f 2 | tail -n +2)
                    do
                        echo Found: "${tag}"
                        if [ \$version = "${tag}" ]; then
                            echo -n false
                            exit 0
                        fi
                    done
                    echo -n true
                    ''').trim()}"""
                    echo "Requires Building: \${requiresBuilding}"
                }
                echo "Version: ${version}"
            }
        }
        stage('Build docker image') {
            when { expression { return env.requiresBuilding }}
            steps {
                sh 'docker build -t netpass_builder:${version} -t netpass_builder:latest -f ./Dockerfile ./'
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}