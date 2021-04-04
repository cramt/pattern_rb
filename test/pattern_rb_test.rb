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
          "the middle one is #{match_data[1]}"
        end
      end
      _(matcher.call("abc")).must_equal "the middle one is b"
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
  end
end
