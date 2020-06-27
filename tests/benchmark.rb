# frozen_string_literal: true

require 'benchmark'
require 'fileutils'
require "open3"
# require_relative '../compiler'

def copy_to_input_file(input_name)
  FileUtils.cp("./benchmark_inputs/#{input_name}", '.input')
end

$stdout = File.new("benchmark_#{Time.new.strftime("%Y%m%d_%H%M%S")}.txt", 'w')
$stdout.sync = true

def execute_compiler(targets:)
  env = {
    "RBS_TEST_TARGET" => targets.join(","),
    "RBS_TEST_OPT" => "-I../sig"
  }

  out, status = Open3.capture2e(env, "ruby", "-rrbs/test/setup", "../compiler.rb")

  STDERR.puts out

  raise unless status.success?
end

Dir.entries('./benchmark_inputs').reject { |f| File.directory? f }.each do |file|
  puts file
  puts '-------------------------------------'
  Benchmark.bm do |x|
    copy_to_input_file file
    x.report('vanilla:') { `ruby ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('No test:') { execute_compiler(targets: ["Steep"]) }
    p
    copy_to_input_file file
    x.report('Lexer:') { execute_compiler(targets: ["Lexer"]) }
    p
    copy_to_input_file file
    x.report('Parser:') { execute_compiler(targets: %w(Parser)) }
    p
    copy_to_input_file file
    x.report('Parser+Lexer:') { execute_compiler(targets: %w(Lexer Parser)) }
    p
    copy_to_input_file file
    x.report('Whole Interpreter:') { 
      execute_compiler(targets: %w(Lexer Parser CodeGenerator CodeOptimizer TargetCodeGenerator Interpreter))
    }
    p
    copy_to_input_file file
    x.report('All classes:') {
      execute_compiler(targets: %w(Token TurnToken CodeTkn Char Lexer Parser CodeGenerator CodeOptimizer TargetCodeGenerator Interpreter))
    }
  end
  puts "\n"

  # puts `time ruby ../compiler.rb`
  # Open3.popen3("") do |stdin, stdout, stderr, thread|
  #  # pid = thread.pid
  #  puts stdout.read.chomp
  #  puts stderr.read.chomp
  # end
end

$stdout = STDOUT
