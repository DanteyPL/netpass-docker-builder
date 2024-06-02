pipeline {
    agent {
        label 'mikrus'
    }
    environment {
        forcePrune = false
        version = """${sh( returnStdout: true, script: "grep version Dockerfile | cut -d'\"' -f2 | tr -d '\\n' ")}"""
        requiresBuilding = """${sh(returnStdout: true, script: '''
                for tag in $(docker images netpass_builder | sed -Ee 's/ +/ /gm' | cut -d" " -f 2 | tail -n +2)
                do
                    echo Found: "$tag"
                    if [ "$tag" = "${version}" ]; then
                        echo -n false
                        exit 0
                    fi
                    echo -n true
                done
                ''').trim()}"""
    }
    stages {
        stage('Show variables') {
            steps {
                echo "Version: ${version}"
                echo "Requires Building: ${requiresBuilding}"
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