elifePipeline {
    def commit
    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    node('containers-jenkins-plugin') {
        stage 'Build images', {
            checkout scm
            sh "IMAGE_TAG=${commit} ./build.sh"
        }

        stage 'Smoke tests', {
            try {
                sh "IMAGE_TAG=${commit} ./run.sh &"
                sh "docker-wait-healthy loris 60"
            } finally {
                sh "docker stop loris"
            }
        }
    }

    stage 'Deploy on ci, continuumtest', {
        elifeMainlineOnly {
            def deployments = [
                ci: {
                    lock('iiif--ci') {
                        builderDeployRevision 'iiif--ci', commit
                        builderSmokeTests 'iiif--ci', '/opt/loris'
                    }
                },
                continuumtest: {
                    lock('iiif--continuumtest') {
                        builderDeployRevision 'iiif--continuumtest', commit
                        builderSmokeTests 'iiif--continuumtest', '/opt/loris'
                    }
                }
            ]
            parallel deployments
        }
    }

    // deploy on end2end and run the elife-spectrum tests
    stage 'End2end tests', {
        elifeSpectrum(
            deploy: [
                stackname: 'iiif--end2end',
                revision: commit,
                folder: '/opt/loris',
                concurrency: 'blue-green'
            ]
        )
    }

    stage 'Deploy to prod', {
        lock('iiif--prod') {
            builderDeployRevision 'iiif--prod', commit, 'blue-green'
            builderSmokeTests 'iiif--prod', '/opt/loris'
        }
    }
}
