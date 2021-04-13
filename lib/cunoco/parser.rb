module Cunoco
  class Parser
    attr_reader :parse_stack
    def initialize(symbol_list)
      @symbol_list = symbol_list
      @parse_stack = []
      @type_stack = []
      @i = 0
      @next_s = ''
      @stop = false
      @prev_is_exp = false
      parse
    end

    def shift(symbol)
      @parse_stack.push(symbol)
      symbol.type == 'B' ? @type_stack.push(symbol.token) : @type_stack.push(symbol.type)
    end

    def rule_finder(string)
      # Rule 1: Turn+Symbol to Move
      index = (string =~ /(TS*)|(T|t)(S)+/)
      return [1, index] if index

      # Rule 2: Sub-alg ->  Alg block
      index = (string =~ /(\((A|t)+\)|bS)/)
      return [2, index] if index

      # Rule 3 Alg-block and Sub-alg -> Alg
      index = (string =~ /A*(b|t)+/)
      return [3, index] if index

      # Does not obey any rule
      0
    end

    def rule1
      # puts "#Rule 1: Turn+Symbol to Move"
      symbols = []
      while @i < @type_stack.length
        type = @type_stack[@i]
        token = @parse_stack[@i].token
        if type == 'T' || type == 't'
          turn = token
          if type == 't'
            @parse_stack[@i].symbol.each do |symbol|
              symbols.push(symbol) if symbol
            end
          end
        elsif type == 'S'
          if (token.is_a? Numeric) && (@next_s.token.is_a? Numeric)
            abort 'Syntax Error: Integer cannot follow another Integer! '
     end
          if @prev_is_exp && (@next_s.token.is_a? Numeric)
            abort "Syntax Error: An integer cannot follow an expression with both an integer and a symbol (n' and 'n)!"
     end
          a = @prev_is_exp
          @prev_is_exp = !a && (token == "'") ^ (@next_s.token == "'")
          symbols.push(token)
        else
          print "This shouldn't happen"
        end
        @type_stack.delete_at(@i)
        @parse_stack.delete_at(@i)
      end
      if symbols.length == 3
        abort "Syntax Error: A prime symbol (') cannot follow an expression with an integer and a symbol (n') due to ambiguity!"
   end
      symbols.push 1 unless (@next_s.type == 'S') || !symbols.empty?
      @type_stack.push('t')
      @parse_stack.push(TurnToken.new(turn, symbols, 't'))
    end

    def rule2
      #   puts "#Rule 2: Alg ->  Alg block"
      turns = []
      symbols = []

      while @i < @type_stack.length
        type = @type_stack[@i]
        token = @parse_stack[@i].token
        if type == 'b'
          turns = token
        elsif type == 'S'
          symbols.push(token)
        elsif type == '(' ||  type == ')'
        elsif type == 'A'
          turns += token
        else
          print type
          print "This shouldn't happen"
        end
        @type_stack.delete_at(@i)
        @parse_stack.delete_at(@i)
      end
      symbols.push 1 unless (@next_s.type == 'S') || !symbols.empty?
      @type_stack.push('b')
      @parse_stack.push(TurnToken.new(turns, symbols, 'b'))
    end

    def rule3
      #   puts "#Rule 3 Alg-block and turns -> Alg"
      turns = []
      return @stop = true if @next_s.type == 'S'

      while @i < @type_stack.length
        type = @type_stack[@i]
        token = @parse_stack[@i].token
        if type == 'A'
          turns = token
        elsif type == 'b' || type == 't'
          turns.push(@parse_stack[@i])
        elsif type == '$'
        else
          print type
          print "This shouldn't happen"
        end
        @type_stack.delete_at(@i)
        @parse_stack.delete_at(@i)
      end
      @type_stack.push('A')
      @parse_stack.push(Token.new(turns, 'A'))
    end

    def reduce
      rule = rule_finder(@type_stack.join)
      act_rule = rule[0]
      @i = rule[1].to_i
      return if act_rule == 0

      case act_rule
      when 1
        rule1
      when 2
        rule2
      when 3
        rule3
      else
        puts "This shouldn't happen"
      end
    end

    def accept
      if @type_stack == ['A'] then nil
      else
        print @type_stack
        puts 'YOOOOOOOOOO'
        @type_stack.each do |c|
          next unless c

          print 'Syntax error: ' + c + 'is not paired!' if c != 'A'
        end
      end
    end

    def parse
      @symbol_list.push Token.new('$', '$')
      @symbol_list.each_cons(2) do |s, next_s|
        #     p "Current symbol: #{s.token} with type #{s.type}; Next symbol: #{next_s.token} with type #{next_s.type}"
        shift(s)
        @next_s = next_s
        reduce while (rule_finder(@type_stack.join) != 0) && !@stop
        @stop = false
      end
      accept
    end
  end
end