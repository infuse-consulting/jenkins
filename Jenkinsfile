#!groovy
import groovy.json.JsonOutput
import groovy.json.JsonBuilder
import groovy.json.JsonSlurper

node {
    try{
        stage('Read and Execute tests') {
            // Obtain credentials for accessing the useMango server, which should be stored in Jenkins with the ID of 'usemango'
            withCredentials([usernamePassword(credentialsId: 'vinay', usernameVariable: 'user', passwordVariable: 'pwd')]) {
                // Obtain values for the server url, project name and folder name from a Jenkins config file, which have the ID
                // that matches the name of the current pipeline job.
                String TEST_SERVICE_URL = "https://e2zkwyufoa.execute-api.eu-west-1.amazonaws.com/v1"
                String SCRIPTS_SERVICE_URL = "https://9viq7bzai3.execute-api.eu-west-1.amazonaws.com/v1"
                String APP_WEBSITE_URL = "https://app.dev.usemango.co.uk"     
                echo "Running tests in project ${params['Project']} with tags ${params['Tags']}"
                def tests = getTests(TEST_SERVICE_URL)
                def testJobs = [:]
                def testResults = [:]
                tests.eachWithIndex { id, index ->
                    echo "Scheduling ${id}"
                        testJobs[id] = {
                            node('usemango-dev') {
                                wrap([$class: "MaskPasswordsBuildWrapper", varPasswordPairs: [[password: ""]]]) {
                                    dir ("${env.WORKSPACE}\\${tests[index]}") {
                                        deleteDir()
                                    }
                                    dir("${env.WORKSPACE}\\${tests[index]}") {
                                        bat "curl -s --create-dirs -L -D \"${env.WORKSPACE}\\${tests[index]}\\response.txt\" -X GET \"${SCRIPTS_SERVICE_URL}/tests/${tests[index]}\" -H \"Authorization: APIKEY ${params['Key']}\" --output \"${env.WORKSPACE}\\${tests[index]}\\${tests[index]}.pyz\""
                                    }
                                    String httpCode = powershell(returnStdout: true, script: "Write-Output (Get-Content \"${env.WORKSPACE}\\${tests[index]}\\response.txt\" | select -First 1 | Select-String -Pattern '.*HTTP/1.1 ([^\\\"]*) *').Matches.Groups[1].Value")                             
                                    echo "Test executable response code - ${httpCode}"
                                    if (httpCode.contains("200")) {
                                        echo "Executing - ${tests[index]}"
                                        try {
                                            dir("${env.WORKSPACE}\\${tests[index]}") {
                                                bat "py ${tests[index]}.pyz " + '-e %user% -p %pwd% -j result.xml'
                                            }
                                            if (fileExists("${tests[index]}\\run.log")) {
                                                dir("${env.WORKSPACE}\\${tests[index]}") {
                                                    String run_id = powershell(returnStdout: true, script: 'Write-Output (Get-Content .\\run.log | select -First 1 | Select-String -Pattern \'.*\\"RunId\\": \\"([^\\"]*)\\"\').Matches.Groups[1].Value')                             
                                                    testResults[tests[index]] = "${tests[index]} (Passed) - ${APP_WEBSITE_URL}/p/${params['Project']}/executions/${run_id}"
                                                }
                                            } else {
                                                testResults[tests[index]] = "${tests[index]} (Failed) - run.log not generated"
                                            }
                                        } catch(Exception ex) {
                                            testResults[tests[index]] = "${tests[index]} (Failed) - Exception occured: ${ex.getMessage()}"
                                        }
                                    } else {
                                        testResults[tests[index]] = "${tests[index]} (Failed) - Unable to get scripted test: ${httpCode}"
                                    }
                                }
                            }
                        }
                }
                parallel testJobs
                boolean allPassed = true
                int passed = 0
                int failed = 0
                echo "useMango Execution results: "
                testResults.eachWithIndex { result, index ->
                    echo "${index + 1}. ${result.value}"
                    if (result.value.contains("Failed")){
                        allPassed = false
                        failed += 1
                    }
                    else {
                        passed += 1
                    }
                }
                echo "Total Executed: ${tests.size()}"
                echo "Passed: ${passed}"
                echo "Failed: ${failed}"
                if (!allPassed){
                    error("Not all the tests passed.")
                }
            }
        }
    } finally{
        node('usemango-dev') {
            wrap([$class: "MaskPasswordsBuildWrapper", varPasswordPairs: [[password: ""]]]) {
                dir("${env.WORKSPACE}\\${tests[index]}") {
                    junit 'result.xml'
                }
            }
        }
    }
}

// Read all tests with the tags specified
def getTests(String baseUrl) {
    String cursor = ""
    def tests = []
    def jsonSlurper = new JsonSlurper()
    echo "Retrieved the following tests from project ${params['Project']} with the tags ${params['Tags']} and status ${params['Status']}"
    while(true) {
        URL url = new URL("${baseUrl}/projects/${params['Project']}/testindex?tags=${params['Tags']}&status=${params['Status']}&cursor=${cursor}")
        HttpURLConnection conn = url.openConnection()
        conn.setRequestMethod("GET")
        conn.setDoInput(true)
        conn.setRequestProperty("Authorization", "APIKEY ${params['Key']}")
        conn.connect()
        String content
        def responseCode = conn.responseCode
        if (responseCode == 200) {
            InputStream inputStream = conn.getInputStream()
            content = inputStream.getText()
        } else {
            throw new Exception("Testindex get request failed with code: ${responseCode}")
        }
        def testPage = jsonSlurper.parseText(content)
        testPage.Items.each{ test -> 
            echo "${test.Name} (${test.Id})"
            tests << test.Id
        }
        if (!testPage.Info.HasNext){
            break
        }
        cursor = testPage.Info.Next
    }
    return tests
}