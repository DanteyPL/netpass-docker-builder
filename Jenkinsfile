pipeline {
    agent {
        label 'mikrus'
    }
    environment {
        forcePrune = false
        version = ''
        requiresBuilding = true
    }
    stages {
        stage('Check if latest image is built') {
            steps {
                    echo 'Checking latest version'
                    sh '''
                    eval $(head -n 2 Dockerfile | tail -n 1 | cut -d' ' -f 2) # retrieving version variable from Dockerfile
                    for tag in $(docker images netpass_builder | sed -Ee 's/ +/ /gm' | cut -d' ' -f 2 | tail -n +2)
                    do
                        if( $tag -eq ${version} )
                        then
                            requiresBuilding = false
                            break
                        fi
                    done
                    '''
                    echo "Version: ${version}"
                    echo "Requires Building: ${requiresBuilding}"
            }
        }
    }
    post {
        cleanup{
            cleanWs()
        }
    }
}