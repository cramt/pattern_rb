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

    def to_a
      [MatchSpalt.new]
    end
  end

  class MatchNoCapture
    def ==(_other)
      true
    end

    def to_a
      [MatchSpalt.new]
    end
  end

  class MatchSpalt
    def ==(_other)
      true
    end
  end
end
