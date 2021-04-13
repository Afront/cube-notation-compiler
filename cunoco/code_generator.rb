module Cunoco
  class CodeGenerator
    attr_reader :code

    def initialize(parse_stack)
      @parse_stack = parse_stack
      @code = []
      generate
    end

    def simplifyToken(token_a)
      code = []
      if token_a.type == 't'
        return [CodeTkn.new(token_a.token, token_a.simplify_symbols)] unless token_a.simplify_symbols == 0
      elsif token_a.type == 'A'
        token_a.token.each do |token|
          code.push *simplifyToken(token)
        end
      elsif token_a.type == 'b'
        token_a.symbol = token_a[1] % 2 ? "'" : '' if token_a.symbol[0] == "'" && (token_a[1].is_a? Integer)
        if token_a.symbol.include? "'"
          token_a.token = token_a.token.reverse
          token_a.token.each do |subtoken|
            if subtoken.symbol.include? "'"
              subtoken.symbol.pop if subtoken.symbol[-1] == "'"
              subtoken.symbol.push(1) if subtoken.symbol.empty?
            elsif subtoken.symbol.length == 1
              subtoken.symbol = [4 - (subtoken.symbol[0] % 4)]
            else
              abort "This shouldn't happen!"
            end
          end
          token_a.symbol.pop
          token_a.symbol.push(1) if token_a.symbol.empty?
        end

        token_a.symbol[0].times do |_time|
          token_a.token.each do |token|
            code.push *simplifyToken(token)
          end
        end
      else
        raise "This shouldn't happen"
      end
      code
    end

    def generate
      @code = simplifyToken(@parse_stack[0])
      raise if @code.nil?
    end
  end
end
