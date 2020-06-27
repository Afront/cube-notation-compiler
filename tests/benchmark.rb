# frozen_string_literal: true

require 'benchmark'
require 'fileutils'
# require_relative '../compiler'

def copy_to_input_file(input_name)
  FileUtils.cp("./benchmark_inputs/#{input_name}", '.input')
end

$stdout = File.new("benchmark_#{Time.new.strftime("%Y%m%d_%H%M%S")}.txt", 'w')
$stdout.sync = true

Dir.entries('./benchmark_inputs').reject { |f| File.directory? f }.each do |file|
  puts file
  puts '-------------------------------------'
  Benchmark.bm do |x|
    copy_to_input_file file
    x.report('vanilla:') { `ruby ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('Lexer:') { `RBS_TEST_TARGET='Lexer' ruby -r rbs/test/setup ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('Parser:') { `RBS_TEST_TARGET='Parser' ruby -r rbs/test/setup ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('Parser+Lexer:') { `RBS_TEST_TARGET='Parser,Lexer' ruby -r rbs/test/setup ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('Whole Interpreter:') { `RBS_TEST_TARGET='Lexer,Parser,CodeGenerator,CodeOptimizer,TargetCodeGenerator,Interpreter' ruby -r rbs/test/setup ../compiler.rb` }
    p
    copy_to_input_file file
    x.report('All classes:') { `RBS_TEST_TARGET='Token,TurnToken,CodeTkn,Char,Lexer,Parser,CodeGenerator,CodeOptimizer,TargetCodeGenerator,Interpreter' ruby -r rbs/test/setup ../compiler.rb` }
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
