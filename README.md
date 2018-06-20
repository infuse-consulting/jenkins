# Parallel execution of useMango tests on Jenkins
Parallel execution of useMango tests with Jenkins CI.

This Jenkinsfile is designed to run within a Jenkins pipeline job. It defines the following steps:

1. Read credentials and definitions of which server, project and folder to run tests from
2. Connects to the server and obtains the list of tests in the specified project and folder
3. For each test found, create a separate Jenkins job to run the test on a separate test node labelled _usemango_ and that can run in parallel
4. At the end of each test, report a junit.xml file back to Jenkins with the outcome of the test.

## How to run a batch of useMango tests.

### 1. Organise tests in a useMango project into folders

### 2. Configure Jenkins with the required plugins

### 3. Define settings for a test batch

### 4. Create a pipeline job for a test batch 

### 5. Run a test batch and observe the results