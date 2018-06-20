#!groovy
import groovy.json.JsonOutput
import groovy.json.JsonSlurper

node {
	stage('Read test names') {
	    stash name: 'scripts', includes: 'um2junit.rb'
        // Obtain credentials for accessing the useMango server, which should be stored in Jenkins with the ID of 'usemango'
	    withCredentials([usernamePassword(credentialsId: 'usemango', usernameVariable: 'user', passwordVariable: 'pwd')]) {
            // Obtain values for the server url, project name and folder name from a Jenkins config file, which have the ID
            // that matches the name of the current pipeline job.
            configFileProvider([configFile(fileId: env.JOB_NAME, targetLocation: 'test.props')]) {
                def props = readProperties file: 'test.props'
                echo "Running tests for server ${props.server}, project ${props.project}, folder ${props.folder}"
                def credentials = [Email:user,Password:pwd,ExecutionOnly:true]
                String cookie = getAuthenticationCookie(props.server, credentials)
                def tests = getTests(props.server, props.project, props.folder, cookie)
                def testJobs = [:]
                for (testname in tests) {
                    def tn = testname
                    echo "Scheduling ${tn}"
                    testJobs[tn] = {
                        node('usemango') {
                            try {
                                unstash 'scripts'
                                bat "\"%programfiles(x86)%\\Infuse Consulting\\useMango\\App\\MangoMotor.exe\" -s ${props.server} -p ${props.project} --testname \"${tn}\" -e ${user} -a ${pwd}"
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

// Create a session on the server and return the authentication cookie
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

// Read all tests from the server whose folder matches the folder argument,
// returning a list of the test names.
def getTests(String baseUrl, String project, String folder, String authCookie) {
    int pageSize = 20
    int offset = 0
    def tests = []
    def jsonSlurper = new JsonSlurper()
    // loop to read tests page by page
    while(true) {
        URL url = new URL("${baseUrl}/projects/${project}/tests?offset=${offset}&pageSize=${pageSize}");
        String content = url.getText(requestProperties:['Cookie':authCookie]);
        def testPage = jsonSlurper.parseText(content)
        // Select the matching tests and append them to the tests list
        def testsInFolder = testPage.Items.findResults { test -> test.Folder == folder ? test : null }
        testsInFolder.each{test -> tests << test.Name}
        offset += testPage.Items.size()
        if (offset >= testPage.FullCount){
            break
        }
    }
    return tests
}