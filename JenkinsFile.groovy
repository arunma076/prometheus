pipeline {
    agent any

    stages {
        stage('Fetching the code') {
            steps {
                git branch: 'main', url: 'https://github.com/arunma076/prometheus.git'
            }
        }

        stage('Configuring changes') {
            steps {
                script {
                    sh 'sudo cp -f prometheus/prometheus.yml /etc/prometheus/prometheus.yml'
                }
            }
        }

        stage('Restarting the service') {
            steps {
                script {
                    def status = sh(script: 'sudo systemctl restart prometheus.service && sleep 5 && sudo systemctl status prometheus.service', returnStatus: true)

                    if (status == 0) {
                        echo 'Prometheus service restarted successfully.'
                    } else {
                        error 'Failed to restart Prometheus service.'
                    }
                }
            }
        }
    }

    post {
        always {
            // Cleanup actions can go here
        }

        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the status of Prometheus service.'
        }
    }
}
