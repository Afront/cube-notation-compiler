# frozen_string_literal: true

require 'fileutils'
require 'open3'

module QuickTest
  @benchmark_dir = "#{__dir__}/benchmark_inputs"
  @interpreter_classes = %w[
    Lexer Parser
    CodeGenerator CodeOptimizer
    TargetCodeGenerator Interpreter
  ]
  @copy_to_input_file = ->(input_name) { FileUtils.cp("#{@benchmark_dir}/#{input_name}", '.input') }

  module_function

  def execute_compiler(targets:)
    env = {
      'RBS_TEST_TARGET' => targets.join(','),
      'RBS_TEST_OPT' => '-I../sig'
    }

    out, status = Open3.capture2e(env, 'ruby', '-rbundler/setup', '-rrbs/test/setup', '../compiler.rb')
    warn out
    raise unless status.success?
  end

  def run_test
    file = Dir.entries(@benchmark_dir).reject { |f| File.directory? f }.sample
    @copy_to_input_file.call file

    execute_compiler(targets: %w[Lexer Parser])
  end
end

QuickTest.run_test
