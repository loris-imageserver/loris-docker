elifePipeline {
    def commit
    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    node('containers-jenkins-plugin') {
        stage 'Build images', {
            checkout scm
            sh 'docker build --tag loris .'
        }

        stage 'Smoke tests', {
            try {
                sh 'docker run --name loris--inst loris &'
                sh 'docker-wait-healthy loris--inst 60'
            } finally {
                sh 'docker stop loris--inst'
                sh 'docker rm -f loris--inst'
            }
        }

        elifeMainlineOnly {
            stage 'Push images', {
                image = DockerImage.elifesciences(this, "loris", commit)
                image.push().tag('latest').push()
            }
        }
    }
}
