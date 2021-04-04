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

  class MultipleSplats < StandardError

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
      @elements = ElementCollection.new elements
      @block = block
      raise(ArityMisMatch.new) unless @block.arity == @elements.total_arity
    end

    def call(*args)
      @block.call(*@elements.generate_argument_list(args))
    end

    def match?(*args)
      @elements.matches(args)
    end
  end
end
