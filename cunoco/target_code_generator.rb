  class TargetCodeGenerator
    attr_reader :target_code

    def initialize(optimized_code)
      @optimized_code = optimized_code
      @target_code_a = []
      generate
      @target_code = @target_code_a.join
    end

    def generate
      @optimized_code[0].length.times do |token|
        @target_code_a.push @optimized_code[0][token]
        @target_code_a.push @optimized_code[1][token]
      end
    end
  end
