module Pattern
  class MatchVar
    @match_vars = {}

    def self.for(symbol)
      @match_vars[symbol] ||= MatchVar.new(symbol)
    end

    attr_reader :sym

    def initialize(sym)
      @sym = sym
    end

    def ==(_other)
      true
    end

    def to_s
      "MatchVar<#{@sym}>"
    end

    def arity
      1
    end
  end

  class MatchNoCapture
    def ==(_other)
      true
    end

    def arity
      0
    end
  end
end
