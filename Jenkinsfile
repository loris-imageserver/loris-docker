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

        elifePullRequestOnly {
            def branchName = env.CHANGE_BRANCH
            def tagName = branchName.replaceAll("/", "_")
            image.tag(tagName).push()
        }

        elifeMainlineOnly {
            stage 'Push image', {
                image = DockerImage.elifesciences(this, "loris", commit)
                image.push()
            }
        }
    }

    elifeMainlineOnly {
        stage 'Deploy on ci, continuumtest', {
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

        stage 'End2end tests', {
            elifeSpectrum(
                deploy: [
                    stackname: 'iiif--end2end',
                    revision: commit,
                    folder: '/opt/loris',
                    concurrency: 'blue-green',
                    rollbackStep: {
                        // revert to 'latest'. not great but better than the default 'approved',
                        // which doesn't exist for this project.
                        builderDeployRevision 'journal-cms--end2end', 'latest'
                        builderSmokeTests 'iiif--end2end', '/opt/loris'
                    }
                ]
            )
        }

        stage 'Deploy to prod', {
            lock('iiif--prod') {
                builderDeployRevision 'iiif--prod', commit, 'blue-green'
                builderSmokeTests 'iiif--prod', '/opt/loris'
            }
        }

        node('containers-jenkins-plugin') {
            stage 'Tag image', {
                image = DockerImage.elifesciences(this, "loris", commit)
                image.tag('latest').push()
            }
        }
    }
}
