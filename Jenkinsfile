pipeline {
    agent none
    stages {
        stage('test') {
            agent { label 'master'}
            steps {
                configFileProvider(
					[configFile(fileId: 'usemango', targetLocation: 'test.props'),
					configFile(fileId: 'testset', targetLocation: 'list.txt')]) {
					script {
						def props = readProperties file: 'test.props'
						def tests = readFile('list.txt').split('\\r?\\n')
						def branches = [:]
						for (testName in tests) {
							def tn = testName
							echo "Scheduling ${tn}"
							branches[tn] = {
								node('usemango') {
									try {
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