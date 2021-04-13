module Cunoco
  class CodeOptimizer
    attr_reader :optimized_code

    def initialize(generated_code)
      @generated_code = generated_code
      @optimized_code = []
      optimize
    end

    def optimize
      turn_list = []
      symbol_list = []
      @generated_code.each do |token|
        if token.turn != turn_list[-1]
          turn_list.push token.turn
          symbol_list.push token.symbol
        else
          symbol_list[-1] = (symbol_list[-1] + token.symbol)
        end
      end
      @optimized_code = [turn_list, symbol_list]
    end
  end
end