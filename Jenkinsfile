pipeline {
    agent any

    triggers {
        cron('H 0 * * 0') // Runs every Sunday at midnight
    }

    stages {
        stage('Auto Merge Dependabot PRs') {
            steps {
                script {
                    // Check if the PR is from Dependabot
                    if (env.CHANGE_AUTHOR ==~ /dependabot[\w\-\.]+/) {
                        // Merge the PR
                        sh 'git config --global user.email "you@example.com"'
                        sh 'git config --global user.name "Your Name"'
                        sh 'git merge --no-ff ${env.CHANGE_ID}'
                    }
                }
            }
        }
    }
}