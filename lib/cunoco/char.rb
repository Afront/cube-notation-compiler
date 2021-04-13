module Cunoco
  class Char
      attr_reader :c

      def initialize(c)
        @c = c
      end


      def is()
        
      end

      def isTurn
        @c =~ /U|D|L|R|F|B/
      end

      def isSlice
        @c =~ /M|E|S/
      end

      def isWide
        @c =~ /u|d|l|r|f|b/
      end

      def isRotation
        @c =~ /[X-Z]|[x-z]/
      end

      def isMove

        isTurn || isSlice || isWide || isRotation
      end

      def isSymbol
        @c =~ /([0-9]|')/
      end

      def isBracket
        @c =~ /[(-)]/
      end

      def is_valid_type
        isMove || isSymbol || isBracket
      end

      def find_type
        return 'T' if isMove
        return 'S' if isSymbol
        return 'B' if isBracket
      end
    end
end