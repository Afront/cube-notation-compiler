# frozen_string_literal: true

# Require dyanmically? => might be a bad idea
require_relative "cunoco/char"
require_relative "cunoco/lexer"
require_relative "cunoco/parser"
require_relative "cunoco/code_generator"
require_relative "cunoco/code_optimizer"
require_relative "cunoco/target_code_generator"

module Cunoco
  Token = Struct.new(:token, :type)
  TurnToken = Struct.new(:token, :symbol, :type) do
    def simplify_symbols
      aSymbols = symbol
      num = -1
      if aSymbols.length == 1
        num = if aSymbols[0] == "'"
                3
              else
                aSymbols[0]
              end
      elsif aSymbols.length == 2
        num = aSymbols[0] == "'" ? 3 * (aSymbols[1] % 2) : 4 - (aSymbols[0] % 4)
        num = 1 if num == 0
      elsif aSymbols.empty?
        num = 0
      end # no else
      return num unless num == -1
    end
  end

  CodeTkn = Struct.new(:turn, :symbol)



  def self.compile(text) 
      lexer = Lexer.new text
      parser = Parser.new lexer.symbol_list
      code_generator = CodeGenerator.new parser.parse_stack
      code_optimizer = CodeOptimizer.new code_generator.code
      target_code_generator = TargetCodeGenerator.new code_optimizer.optimized_code
      return target_code_generator.target_code
  end


  if $PROGRAM_NAME == __FILE__ 
    raise ArgumentError, "Not enough arguments!" if ARGV.size != 1
    puts 1compile(File.read(ARGV.first))
  end
end
