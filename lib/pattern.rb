# frozen_string_literal: true

require "pattern/version"
require "pattern/element"
require "pattern/match_types"
require "pry"

module Pattern
  class NoMatchingPattern < StandardError

  end

  class ArityMisMatch < StandardError

  end

  class Pattern
    def initialize(&block)
      @context = PatternContext.new
      @context.instance_eval(&block)
    end

    def call(*args)
      @context._call(*args)
    end
  end

  def self.new(&block)
    Pattern.new(&block)
  end

  class PatternContext
    def initialize
      @patterns = []
    end

    def pattern(*args, &block)
      @patterns << Example.new(args, block)
    end

    def method_missing(symbol, *_)
      MatchVar.for symbol
    end

    def respond_to_missing?(symbol, *args)
      return super unless args.empty?

      true
    end

    def _matching_pattern(*args)
      @patterns.detect(-> {raise NoMatchingPattern.new}) do |x|
        x.match?(*args)
      end
    end

    def _
      MatchNoCapture.new
    end

    def _call(*args)
      _matching_pattern(*args).call(*args)
    end
  end

  class Example
    def initialize(elements, block)
      @elements = elements.map do |x|
        Element.for x
      end
      @block = block
      total_arity = @elements.map {|x|x.arity}.sum
      raise(ArityMisMatch.new) unless @block.arity == total_arity
    end

    def call(*args)
      @elements.each do |element|
        element.mutate(args)
      end
      @block.call(*args)
    end

    def match?(*args)
      @elements.zip(args).all? do |element, value|
        element == value
      end
    end
  end
end
