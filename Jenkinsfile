
pipeline {
    agent {	
        label 'linux'
    }

    options {
        withFolderProperties()
    }

    stages {
        stage('Docker build + push') {
            when { anyOf { branch 'main'; branch 'develop' } }
            steps {
                script {
                    def config = readJSON file: 'config.json'

                    def dockerName = config.imageName
                    def dockerFolder = env.DOCKER_FOLDER
                    def dockerBranch = ""

                    if(env.BRANCH_NAME != 'master') {
                        dockerFolder += '-dev'
                    }

                    docker.withRegistry('https://'+env.DOCKER_REGISTRY, env.DOCKER_REGISTRY_USER) {
                        def image = docker.build("${dockerFolder}/${dockerName}:${config.version}${dockerBranch}")
                        // image.push()
						echo "Haria push de la imagen ${dockerFolder}/${dockerName}:${config.version}${dockerBranch} al registro ${env.DOCKER_REGISTRY}"
                        sh "docker rmi ${image.id}"
                    }
                } 
            }
        }
		stage('Update K8s Deployment') {
			steps {
				withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
					script {
						// Actualiza el deployment de Kubernetes con la nueva imagen (si el kubeconfig está en ~/.kube/config, no es necesario especificar la ruta)
						// sh "kubectl --kubeconfig=${KUBECONFIG} -n mopa set image deployment/sira-dev sira-dev=${env.DOCKER_REGISTRY}/${env.DOCKER_FOLDER}/${dockerName}:${config.version}${dockerBranch}"
						// sh "kubectl --kubeconfig=${KUBECONFIG} -n mopa rollout restart deployment/sira-dev"
						echo "kubectl --kubeconfig=${KUBECONFIG} -n mopa set image deployment/sira-dev sira-dev=${env.DOCKER_REGISTRY}/${dockerFolder}/${dockerName}:${config.version}${dockerBranch}"
						echo "kubectl --kubeconfig=${KUBECONFIG} -n mopa rollout restart deployment/sira-dev"
					}
				}
			}
		}
    }
}
