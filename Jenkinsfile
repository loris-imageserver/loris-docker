elifePipeline {
    def commit
    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    node('containers-jenkins-plugin') {
        stage 'Build images', {
            checkout scm
            sh 'IMAGE_TAG=${commit} ./build.sh'
        }

        stage 'Smoke tests', {
            try {
                sh 'IMAGE_TAG=${commit} ./run.sh &'
                sh 'docker-wait-healthy loris 60'
            } finally {
                sh 'docker stop loris'
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
