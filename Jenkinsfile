#!groovy
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

node {
	stage('Read test names') {
	    stash name: 'scripts', includes: 'RunTest.cmd,um2junit.rb'
	    withCredentials([usernamePassword(credentialsId: 'usemango', usernameVariable: 'user', passwordVariable: 'pwd')]) {
            configFileProvider([configFile(fileId: env.JOB_NAME, targetLocation: 'test.props')]) {
                def props = readProperties file: 'test.props'
                echo "Running tests for server ${props.server}, project ${props.project}, folder ${props.folder}"
                def credentials = [Email:user,Password:pwd,ExecutionOnly:true]
                String cookie = getAuthenticationCookie(props.server, credentials)
                def tests = getTests(props.server, props.project, props.folder, cookie)
                def testJobs = [:]
                for (tn in tests) {
                    echo "Scheduling ${tn}"
                    testJobs[tn] = {
                        node('usemango') {
                            try {
                                unstash 'scripts'
                                bat "runtest.cmd ${server} ${project} \"${testName}\" ${user} ${pwd}"
                            }
                            finally {
                                bat "um2junit.rb \"%PROGRAMDATA%\\useMango\\logs\\run.log\" > junit.xml"
                                junit 'junit.xml'
                            }
                        }
                    }
                }
                parallel testJobs
            }
	    }
	}
}

def getAuthenticationCookie(String baseUrl, Object data) {
    URL url = new URL("${baseUrl}/session")
    HttpURLConnection conn = url.openConnection()
    conn.setDoOutput(true)
    conn.setRequestMethod("POST")
	setRequestContent(conn, data)
    conn.connect()
    List<String> cookies = conn.getHeaderFields().get("Set-Cookie")
    if (cookies.any()) {
		return cookieValue(cookies.first())
	}
    else
        throw new Exception("No cookies found")
}

def cookieValue(String cookieHeader) {
	return cookieHeader.substring(0, cookieHeader.indexOf(";"))
}

def setRequestContent(HttpURLConnection conn, Object data) {
    conn.setRequestProperty("Content-Type", "application/json")
    OutputStreamWriter out = new OutputStreamWriter(conn.getOutputStream())
    out.write(JsonOutput.toJson(data))
    out.flush()
    out.close()
}

def getTests(String baseUrl, String project, String folder, String authCookie) {
    int pageSize = 20
    int offset = 0
    def tests = []
    def jsonSlurper = new JsonSlurper()
    while(true) {
        URL url = new URL("${baseUrl}/projects/${project}/tests?offset=${offset}&pageSize=${pageSize}");
        String content = url.getText(requestProperties:['Cookie':authCookie]);
        def testPage = jsonSlurper.parseText(content)
        def testsInFolder = testPage.Items.findResults { test -> test.Folder == folder ? test : null }
        testsInFolder.each{test -> tests << test.Name}
        offset += testPage.Items.size()
        if (offset >= testPage.FullCount){
            break
        }
    }
    return tests
}