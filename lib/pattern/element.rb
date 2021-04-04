module Pattern
  class Element
    def initialize(inner)
      @inner = inner
    end

    def self.for(inner)
      case inner
      when MatchVar
        VarElement.new inner
      when MatchNoCapture
        BlankElement.new inner
      else
        if inner.respond_to?(:match?) || inner.respond_to?(:cover?)
          CustomElement.new inner
        else
          ConstElement.new inner
        end
      end
    end
  end

  class VarElement < Element
    def arity
      1
    end

    def ==(_other)
      true
    end

    def mutate(_)
      self
    end
  end

  class ConstElement < Element
    def arity
      0
    end

    def ==(other)
      @inner == other
    end

    def mutate(args)
      args.shift
      self
    end
  end

  class BlankElement < Element
    def arity
      0
    end

    def ==(_other)
      true
    end

    def mutate(args)
      args.shift
      self
    end
  end

  class CustomElement < Element
    def arity
      1
    end

    def ==(other)
      @inner === other
    end

    def mutate(_)
      self
    end
  end
end
