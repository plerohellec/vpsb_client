module LogfileInterval
  module Aggregator
    class Pxx < Base
      def initialize(options)
        super
        @val = PxxBuckets.new(options)
      end

      def add(value, group_by = nil)
        raise NotImplementedError if group_by
        @val.increment(value)
      end

      def value(group)
        @val.value(group.to_f / 100.0)
      end

      def single_value?
        false
      end
    end

    class OneHundredMinusPxx < Pxx
      def add(value, group_by = nil)
        raise NotImplementedError if group_by
        @val.increment(100.0 - value)
      end
    end
  end
end

class PxxBuckets
  attr_reader :buckets, :ary, :total

  def initialize(options)
    i = 0
    @ary = [ 0 ]
    ranges = options.fetch(:ranges)
    ranges.keys.each do |ceiling|
      while(i < ceiling)
        i += ranges[ceiling]
        i = i.round(2) if i.is_a?(Float) # float decimal errors
        @ary << i
      end
    end

    @buckets = {}
    @ary.each do |min|
      @buckets[min] = 0
    end

    @pxx_keys = options.fetch(:pxx_keys)
    @total = 0
  end

  def keys
    @pxx_keys
  end

  def each_key(&block)
    keys.each(&block)
  end

  def [](key)
    value(key.to_f/100.0)
  end

  def increment(n)
    k = find_bucket_key(n)
    @buckets[@ary[k]] += 1
    @total += 1
  end

  def empty?
    return total==0
  end

  def value(percent)
    target = @total.to_f * (1.0 - percent)
    sum = 0
    @buckets.keys.sort.reverse.each do |floor|
      sum += @buckets[floor]
#       puts "target=#{target} floor=#{floor} sum=#{sum}"
      return floor if sum >= target
    end
  end

  def find_bucket_key(n)
    idx = (0...@ary.size).bsearch do |i|
      @ary[i] > n
    end
    idx ? idx - 1 : @ary.size - 1
  end
end
