pipeline {
		agent none
		stages {
			stage('Running tests') {
				agent { label 'master'}
				steps {
					stash name: 'scripts', includes: 'RunTest.cmd,um2junit.rb' 
					withCredentials([usernamePassword(credentialsId: 'usemango', usernameVariable: 'user', passwordVariable: 'pwd')]) {
					configFileProvider([configFile(fileId: env.JOB_NAME, targetLocation: 'test.props')]) {
						script {
							def props = readProperties file: 'test.props'
							bat "ruby listtests.rb ${props.server} ${props.project} ${props.folder} ${user} ${pwd} > list.txt"
							def tests = readFile('list.txt').split('\\r?\\n')
							def branches = [:]
							for (testName in tests) {
								def tn = testName
								echo "Scheduling ${tn}"
								branches[tn] = {
									node('usemango') {
										try {
											unstash 'scripts'
											bat "runtest.cmd ${props.server} ${props.project} \"${tn}\""
										}
										finally {
											bat "ruby um2junit.rb \"%PROGRAMDATA%\\useMango\\logs\\run.log\" > junit.xml"
											junit 'junit.xml'
										}
									}
								}
							}
							parallel branches
						}
					}
				}
			}
		}
	}
}