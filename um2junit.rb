require 'builder'
require 'json'

class UMTestResult
  def initialize(log_path)
    file = File.open(log_path)
    @events = file.readlines("\n").map{|line| JSON.parse(line)}
  end

  def name
    @events[0]["TestName"]
  end

  def failed?
    result = @events.last["Result"]
    return true if result.nil?
    result.downcase != 'passed'
  end

  def error_data
    errmsg = @events.map{ |e| e['@m'] }.select { |msg| (msg.include? "StepCompleted Failed") || (msg.include? "Last reported error") }.first
    errmsg.nil? ? "Unknown error" : errmsg
  end

  def duration
    @events.last["ElapsedMS"] / 1000
  end
end

if ARGV.length == 0
  $stderr.puts 'No input log file given.'
  $stderr.puts 'Usage: ruby um2junit.rb run.log'
  exit 1
end

input_path = ARGV[0]
unless File.exist?(input_path)
  $stderr.puts "No such log file: #{input_path}"
  exit 1
end

builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
um_result = UMTestResult.new(input_path)
builder.testsuite() do |testsuite|
  testsuite.testcase(classname: "useMango", name: um_result.name, time: um_result.duration) do |test|
    if um_result.failed?
      type = 'test step failure'
      test.failure(type: type) do |failure|
        failure.cdata! um_result.error_data
      end
    end
  end
end
builder.target!