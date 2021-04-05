# frozen_string_literal: true

require "test_helper"

describe Pattern do
  describe "when called with 1 param" do
    it "matches constants" do
      matcher = Pattern.new do
        pattern(0) do
          "zero gang"
        end
        pattern(1) do
          "one gang"
        end
      end
      _(matcher.call(1)).must_equal "one gang"
    end
    it "matches any single variable" do
      matcher = Pattern.new do
        pattern(a) do |a|
          "its #{a}"
        end
      end
      _(matcher.call(1)).must_equal "its 1"
      _(matcher.call(2)).must_equal "its 2"
    end
    it "raises error when no patterns match" do
      matcher = Pattern.new do

      end
      _(-> { matcher.call(0) }).must_raise(Pattern::NoMatchingPattern)
    end
    it "matches regex constants" do
      matcher = Pattern.new do
        pattern(/.(.)./) do |match_data|
          "the middle one is #{match_data[0]}"
        end
      end
      _(matcher.call("abc")).must_equal "the middle one is b"
    end
    it "matches 2 regex constants" do
      matcher = Pattern.new do
        pattern(/.(..)(..)/) do |match_data|
          "the middle one is #{match_data[0]}, and the last one is #{match_data[1]}"
        end
      end
      _(matcher.call("abbcc")).must_equal "the middle one is bb, and the last one is cc"
    end
    it "matches range constants" do
      matcher = Pattern.new do
        pattern(5..9) do |n|
          "the square of #{n} is #{n ** 2}"
        end
      end
      _(matcher.call(6)).must_equal "the square of 6 is 36"
    end
    it "can recursively implement even" do
      matcher = Pattern.new do
        pattern(1) do
          false
        end
        pattern(2) do
          true
        end
        pattern(a) do |a|
          matcher.call(a - 2)
        end
      end
      _(matcher.call(7)).must_equal false
      _(matcher.call(10)).must_equal true
    end

    it "raises error when the aritiy of the block and the pattern dont match" do
      _(-> {
        Pattern.new do
          pattern(2) do |a|
            "this should be 2: #{a}"
          end
        end
      }).must_raise(Pattern::ArityMisMatch)
    end

    it "matches nil on var" do
      matcher = Pattern.new do
        pattern(a, b) do |a, b|
          "#{a}, #{b}"
        end
      end
      _(matcher.call(nil, 2)).must_equal ", 2"
    end

    it "matches either between 1 or 0" do
      matcher = Pattern.new do
        pattern(either(1, 0)) do |x|
          "its #{x}"
        end
      end
      _(matcher.call(1)).must_equal "its 1"
      _(matcher.call(0)).must_equal "its 0"
    end
  end
  describe "when called with multiple params" do
    it "omits _ from arg list" do
      matcher = Pattern.new do
        pattern(_, a) do |a|
          "a is #{a}"
        end
      end
      _(matcher.call(1, 2)).must_equal "a is 2"
    end
    it "omits constant from arg list" do
      matcher = Pattern.new do
        pattern(2, a) do |a|
          "second thing is #{a}"
        end
      end
      _(matcher.call(2, "bruh")).must_equal "second thing is bruh"
    end
    it "matches head and splats tail" do
      matcher = Pattern.new do
        pattern(a, *as) do |a, as|
          "#{a} followed by #{as.inspect}"
        end
      end
      _(matcher.call(1, 2, 3)).must_equal "1 followed by [2, 3]"
    end

    it "splats head and matches tail" do
      matcher = Pattern.new do
        pattern(*as, a) do |as, a|
          "#{as.inspect} followed by #{a}"
        end
      end
      _(matcher.call(1, 2, 3)).must_equal "[1, 2] followed by 3"
    end

    it "splits body inbetween matching head and tail" do
      matcher = Pattern.new do
        pattern(a1, *as, a2) do |a1, as, a2|
          "#{as.inspect} is in between #{a1} and #{a2}"
        end
      end
      _(matcher.call(1, 2, 3, 4, 5)).must_equal "[2, 3, 4] is in between 1 and 5"
    end

    it "raises error on multiple splats" do
      _(-> {
        Pattern.new do
          pattern(*as, *bs) do |as, bs|
            "this doesnt matter"
          end
        end
      }).must_raise(Pattern::MultipleSplats)
    end
  end
end
