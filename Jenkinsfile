pipeline {
    agent none
    parameters {
        string(name: 'testset', defaultValue: 'undefined.testset')
        string(name: 'server', defaultValue: 'https://undefined.server')
        string(name: 'project', defaultValue: 'undefined.project')
    }
    stages {
        stage('test') {
            agent { label 'master'}
            steps {
                configFileProvider([configFile(fileId: params.testset, targetLocation: 'list.txt')]) {
                    script {
                        def tests = readFile('list.txt').split('\\r?\\n')
                        def branches = [:]
                        for (testName in tests) {
                            def tn = testName
                            echo "Scheduling ${tn}"
                            branches[tn] = {
                                node('usemango') {
									try {
										bat "\"%programfiles(x86)%\\Infuse Consulting\\useMango\\Scripts\\runtest.cmd\" ${params.server} ${params.project} \"${tn}\""
									}
									finally {
										bat "\"%programfiles(x86)%\\Infuse Consulting\\useMango\\Scripts\\um2junit.rb\" \"%PROGRAMDATA%\\useMango\\logs\\run.log\" > junit.xml"
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