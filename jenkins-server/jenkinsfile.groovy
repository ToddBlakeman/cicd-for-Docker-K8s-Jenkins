def COLOR_MAP = [
	'SUCCESS': 'good',
	'FAILUIRE': 'danger',
]

pipeline {
	agent any
	tools {
		maven "MAVEN3"
		jdk "OracleJDK11"
	}

	stages {
		stage('Fetch Code') {
			steps {
				git branch: 'vp-rem', url:'https://github.com/ToddBlakeman/cicd-for-Docker-K8s-Jenkins'
			}
		}

		stage('Build'){
			steps {
				sh 'mvn install -DskipTests'
			}

			post {
				success {
					echo 'Archiving artifacts now'
					archiveArtifacts artifacts: '**/*.war'
				}
			}
		}

		stage('UNIT TEST'){
			steps {
				sh 'mvn test'
			}
		}

		stage('Checkstyle Analysis'){
			steps {
				sh 'mvn checkstyle:checkstyle'
			}
		}

		stage('Sonar Analysis'){
			environment {
				scannerHome = tool 'sonar4.7'
			}
			steps {
				withSonarQubeEnv('sonar') {
					sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
				}
			}
		}

		stage('Quality Gate'){
			steps {
				timeout(time: 1, unit: 'HOURS'){
					// Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
					// true = set pipeline to UNSTABLE, false = don't
					waitForQualityGate abortPipeline: true
				}
			}
		}
	}
}