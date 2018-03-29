pipeline {
    agent none
    stages {
        stage('test') {
            agent { label 'master'}
            steps {
                stash name: 'scripts', includes: 'RunTest.cmd,um2junit.rb' 
                configFileProvider(
					[configFile(fileId: env.JOB_NAME, targetLocation: 'test.props')]) {
					script {
						def props = readProperties file: 'test.props'
						sh "ruby listtests.rb jenkins@usemango.co.uk ${props.server} ${props.project} ${props.folder} > list.txt"
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
										bat "um2junit.rb \"%PROGRAMDATA%\\useMango\\logs\\run.log\" > junit.xml"
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