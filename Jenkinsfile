#!groovy

node {
	stage('Read test names') {
		echo getAuthenticationCookies('http://52.215.44.149:5000', [Email:"james.johnson@infuse.it",Password:"usemangouser",ExecutionOnly:true])
	}
}

def getAuthenticationCookies(String requestUrl, Object data) {
    URL url = new URL(requestUrl);
    HttpURLConnection conn = url.openConnection();
    conn.setDoOutput(true);
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json");
    OutputStreamWriter out = new OutputStreamWriter(conn.getOutputStream());
    out.write(JsonOutput.toJson(data));
    out.flush();
    out.close();
    conn.connect();
    Map<String, List<String>> headers = conn.getHeaderFields();
    if (headers.containsKey("Set-Cookie"))
    {
        return headers.get("Set-Cookie");
    }
    else
    {
        return new ArrayList<String>();
    }
}

def getHttpRequest(String requestUrl){    
	URL url = new URL(requestUrl);
	url.getText();
	//HttpURLConnection connection = url.openConnection();    
	//connection.setRequestMethod("GET");
	//connection.doOutput = true;   
	//connection.connect();    
} 