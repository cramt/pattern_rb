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
      after_result = after.reverse.map do |element|
        element.mutate(args).first element.arity
      end.flatten(1).reverse
      args = args.reverse
      before.map do |element|
        element.mutate(args).first element.arity
      end.flatten(1).concat after_result
    end

    def generate_argument_list_without_splat(args)
      @inner.map do |element|
        element.mutate(args).first element.arity
      end.flatten(1)
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
      when Range
        CustomElement.new inner
      when Regexp
        RegexElement.new inner
      when MatchOr
        OrElement.new inner
      else
        if inner.respond_to?(:match?)
          CustomElement.new inner
        else
          ConstElement.new inner
        end
      end
    end

    def mutate(args)
      [args.shift]
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
      [args]
    end
  end

  class VarElement < Element
    def arity
      1
    end

    def ==(_other)
      true
    end
  end

  class ConstElement < Element
    def arity
      0
    end

    def ==(other)
      @inner == other
    end
  end

  class BlankElement < Element
    def arity
      0
    end

    def ==(_other)
      true
    end
  end

  class RegexElement < Element
    def arity
      1
    end

    def ==(other)
      @inner === other
    end

    def mutate(args)
      [@inner.match(args.shift).captures]
    end
  end

  class CustomElement < Element
    def arity
      1
    end

    def ==(other)
      @inner === other
    end
  end

  class OrElement < Element
    def initialize(inner)
      super
      @inner = ElementCollection.new inner
    end

    def arity
      1
    end

    def ==(other)
      found = @inner.find { |x| x == other }
      @found = found
      !found.nil?
    end

    def mutate(args)
      @found.mutate(args)
    end
  end
end
