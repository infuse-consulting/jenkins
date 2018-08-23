require 'json'
require 'rest-client'

PG_SIZE = 200

# Class to get things from the rest API
class UMClient

    def initialize(url)
        @url = url.end_with?('/') ? url : url + '/'
        @cookies = {}
    end
  
    def get(sub_url, headers = {})
        url = full_url(sub_url)
        headers[:cookies] = @cookies
        response = RestClient.get(url, headers)
    end
  
    def get_json(sub_url)
        options = {accept: :json}
        get(sub_url, options)
    end
  
    def get_json_parsed(sub_url)
        JSON.parse(get_json(sub_url))
    end
  
    def post(sub_url, object = nil, options = {})
        url = full_url(sub_url)
        options[:cookies] = @cookies
        response = RestClient.post(url, object, options)
        @cookies.merge!(response.cookies)
        response
    end
    
    def post_json(sub_url, object)
        options = { content_type: :json, accept: :json }
        response = post(sub_url, object.to_json, options)
    end

    def full_url(url)
        @url + url
    end

    def tests_in_project(project)
        offset = 0
        tests = []
        begin
            page = get_json_parsed("projects/#{project}/tests?offset=#{offset}&pageSize=#{PG_SIZE}")
            offset = offset + page["Items"].size
            page["Items"].each { |t| tests.push t }
        end while offset < page["FullCount"]
        tests
    end

end

if ARGV.length != 5
  $stderr.puts 'Arguments for server, project, folder, email and password are required.'
  $stderr.puts 'Usage: ruby listtests.rb server project folder email password'
  exit 1
end

url = ARGV[0]
project = ARGV[1]
folder = ARGV[2]
email = ARGV[3]
password = ARGV[4]

client = UMClient.new(url)
login = {'Email' => email, 'Password' => password, 'ExecutionOnly' => false }
client.post_json('session', login)

project_tests = client
    .tests_in_project(project)
    .select { |test| test["Folder"].downcase == folder.downcase }
    .each { |test| puts test["Name"] }