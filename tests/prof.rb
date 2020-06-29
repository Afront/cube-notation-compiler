# frozen_string_literal: true

require 'fileutils'
require 'stackprof'
require_relative '../compiler'

current_time = Time.new.strftime('%Y%m%d_%H%M%S')
prof_dump_directory = "#{__dir__}/tmp/prof/"
file_name = "#{prof_dump_directory}/prof-cpu-cube_notation_compiler_#{current_time}.dump"

FileUtils.mkdir_p prof_dump_directory unless Dir.exist? prof_dump_directory
file = File.new(file_name, 'w')

def copy_to_input_file(input_name)
  FileUtils.cp("#{__dir__}/benchmark_inputs/#{input_name}", '.input')
end

StackProf.run(mode: :cpu, out: file_name) do
  copy_to_input_file('long.cube')
  Interpreter.new
end
