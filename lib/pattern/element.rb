module Pattern
  class ElementCollection
    include Enumerable

    def initialize(values)
      @inner = values.map do |x|
        Element.for x
      end
      raise(MultipleSplats) if @inner.select do |element|
        element.is_a? SplatElement
      end.length > 1
    end

    def total_arity
      @inner.map(&:arity).sum
    end

    def matches(args)
      zip(args).all? do |element, value|
        element == value
      end
    end

    def generate_argument_list(args)
      args = args.clone
      splat_index = contains_splat
      if splat_index
        generate_argument_list_with_splat(args, splat_index)
      else
        generate_argument_list_without_splat(args)
      end
    end

    def generate_argument_list_with_splat(args, splat_index)
      after, before = @inner.partition.with_index { |_, i| i > splat_index }
      args = args.reverse
      after_result = after.reverse.filter_map do |element|
        element.mutate(args)
      end.reverse
      args = args.reverse
      before.filter_map do |element|
        element.mutate(args)
      end.concat after_result
    end

    def generate_argument_list_without_splat(args)
      @inner.filter_map do |element|
        element.mutate(args)
      end
    end

    def contains_splat
      @inner.index do |x|
        x.is_a? SplatElement
      end
    end

    def each(&block)
      @inner.each(&block)
    end
  end

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
      when MatchSpalt
        SplatElement.new inner
      else
        if inner.respond_to?(:match?) || inner.respond_to?(:cover?)
          CustomElement.new inner
        else
          ConstElement.new inner
        end
      end
    end
  end

  class SplatElement < Element
    def arity
      1
    end

    def ==(_other)
      true
    end

    def mutate(args)
      args
    end
  end

  class VarElement < Element
    def arity
      1
    end

    def ==(_other)
      true
    end

    def mutate(args)
      args.shift
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
      nil
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
      nil
    end
  end

  class CustomElement < Element
    def arity
      1
    end

    def ==(other)
      @inner === other
    end

    def mutate(args)
      args.shift
    end
  end
end
