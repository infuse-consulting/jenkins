require 'json'
require 'rest-client'

# Class to get things from the rest API
class UMClient

    def initialize(url)
        @url = url
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

end

if ARGV.length != 4
  $stderr.puts 'Arguments for user, server, project and folder are required.'
  $stderr.puts 'Usage: ruby listtests.rb user server project folder'
  exit 1
end

user = ARGV[0]
url = ARGV[1]
project = ARGV[2]
folder = ARGV[3]

client = UMClient.new(url)
login = { email: user, username: 'test.user' }
client.post_json('users/login', login)
