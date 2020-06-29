# frozen_string_literal: true

require 'benchmark'
require 'fileutils'
require 'open3'

module RBSBenchmark
  @@benchmark_dir = "#{__dir__}/benchmark_inputs"
  @@benchmark_tmp_dir = "#{__dir__}/tmp/benchmark"
  @@token_classes = %w[Token TurnToken CodeTkn Char]
  @@interpreter_classes = %w[
    Lexer Parser
    CodeGenerator CodeOptimizer
    TargetCodeGenerator Interpreter
  ]
  @@copy_to_input_file = ->(input_name) { FileUtils.cp("#{@@benchmark_dir}/#{input_name}", '.input') }

  class BenchmarkReportHelper
    def initialize(file, benchmark, copy_to_input_file_lambda)
      @file = file
      @benchmark = benchmark
      @copy_to_input_file = copy_to_input_file_lambda
    end

    def report(label)
      @copy_to_input_file.call @file
      @benchmark.report("#{label}:") { yield }
      p
    end
  end

  module_function

  def execute_compiler(targets:)
    env = {
      'RBS_TEST_TARGET' => targets.join(','),
      'RBS_TEST_OPT' => '-I../sig'
    }

    out, status = Open3.capture2e(env, 'ruby', '-rrbs/test/setup', '../compiler.rb')
    warn out
    raise unless status.success?
  end

  def setup_path(path_name)
    FileUtils.mkdir_p path_name unless Dir.exist? path_name
  end

  def setup_benchmark
    setup_path @@benchmark_dir
    setup_path @@benchmark_tmp_dir
    $stdout = File.new("#{@@benchmark_tmp_dir}/benchmark_#{Time.new.strftime('%Y%m%d_%H%M%S')}.txt", 'w')
    $stdout.sync = true
  end

  def run_benchmark
    setup_benchmark

    Dir.entries(@@benchmark_dir).reject { |f| File.directory? f }.each do |file|
      puts file
      puts '-------------------------------------'
      Benchmark.bm do |x|
        benchmark_reporter = BenchmarkReportHelper.new(file, x, @@copy_to_input_file)
        benchmark_reporter.report('Vanilla') { `ruby ../compiler.rb` }
        benchmark_reporter.report('No test') { execute_compiler(targets: ['Steep']) }
        benchmark_reporter.report('Lexer') { execute_compiler(targets: ['Lexer']) }
        benchmark_reporter.report('Parser') { execute_compiler(targets: %w[Parser]) }
        benchmark_reporter.report('Parser+Lexer') { execute_compiler(targets: %w[Lexer Parser]) }
        benchmark_reporter.report('Whole Interpreter') do
          execute_compiler(targets: @@interpreter_classes)
        end
        benchmark_reporter.report('All classes') do
          execute_compiler(targets: @@interpreter_classes + @@token_classes)
        end
      end
      puts "\n"
    end

    $stdout = STDOUT
  end
end

RBSBenchmark.run_benchmark
