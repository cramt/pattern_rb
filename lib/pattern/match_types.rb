require "delegate"

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

    def to_s
      "MatchVar<#{@sym}>"
    end

    def to_a
      [MatchSpalt.new]
    end
  end

  class MatchNoCapture
    def to_a
      [MatchSpalt.new]
    end
  end

  class MatchSpalt

  end

  class MatchOr < Delegator
    def initialize(inner)
      super
      @inner = inner
    end

    def __getobj__
      @inner
    end

    def __setobj__(_)

    end
  end
end
