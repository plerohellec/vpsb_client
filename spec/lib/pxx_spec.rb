require 'spec_helper'
require_relative File.expand_path("../../../lib/vpsb_client/datafiles/pxx_aggregator", __FILE__)

describe PxxBuckets do
  before :each do
    @ranges = {
      10 => 5,
      20 => 10
    }
    @pxxbuckets = PxxBuckets.new({ :ranges => @ranges, :pxx_keys => [ 75, 95, 99 ] })
  end

  it 'initializes 4 buckets' do
    expect(@pxxbuckets.buckets.size).to eq(4)
    expect(@pxxbuckets.ary[0]).to eq(0)
    expect(@pxxbuckets.ary[1]).to eq(5)
    expect(@pxxbuckets.ary[2]).to eq(10)
    expect(@pxxbuckets.ary[3]).to eq(20)
  end

  it 'initializes bucket values to 0' do
   expect(@pxxbuckets.buckets.values).to eq([0, 0, 0, 0])
  end

  it 'sets bucket keys to ranges start' do
   expect(@pxxbuckets.buckets.keys).to eq([0, 5, 10, 20])
  end

  describe :find_bucket_key do
    it 'returns bucket indexes' do
      expect(@pxxbuckets.find_bucket_key(0)).to eq(0)
      expect(@pxxbuckets.find_bucket_key(5)).to eq(1)
      expect(@pxxbuckets.find_bucket_key(15)).to eq(2)
      expect(@pxxbuckets.find_bucket_key(1000)).to eq(3)
    end
  end

  it 'places 0 in first bucket' do
    @pxxbuckets.increment(0)
    expect(@pxxbuckets.buckets[0]).to eq(1)
    expect(@pxxbuckets.buckets[5]).to eq(0)
    expect(@pxxbuckets.buckets[10]).to eq(0)
    expect(@pxxbuckets.buckets[20]).to eq(0)
  end

  it 'places 15 in 3rd bucket' do
    @pxxbuckets.increment(15)
    expect(@pxxbuckets.buckets[0]).to eq(0)
    expect(@pxxbuckets.buckets[5]).to eq(0)
    expect(@pxxbuckets.buckets[10]).to eq(1)
    expect(@pxxbuckets.buckets[20]).to eq(0)
  end

  it 'places 1000 in last bucket' do
    @pxxbuckets.increment(1000)
    expect(@pxxbuckets.buckets[0]).to eq(0)
    expect(@pxxbuckets.buckets[5]).to eq(0)
    expect(@pxxbuckets.buckets[10]).to eq(0)
    expect(@pxxbuckets.buckets[20]).to eq(1)
  end

  describe :value do
    it 'finds the pXX value for single high item' do
      @pxxbuckets.increment(1000)
      expect(@pxxbuckets.value(0.50)).to eq(20)
      expect(@pxxbuckets.value(0.75)).to eq(20)
      expect(@pxxbuckets.value(0.95)).to eq(20)
    end

    it 'finds the pXX value for single low item' do
      @pxxbuckets.increment(2)
      expect(@pxxbuckets.value(0.50)).to eq(0)
      expect(@pxxbuckets.value(0.75)).to eq(0)
      expect(@pxxbuckets.value(0.95)).to eq(0)
    end

    it 'finds the pxx value for low majority' do
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(10)
      expect(@pxxbuckets.value(0.50)).to eq(0)
      expect(@pxxbuckets.value(0.75)).to eq(10)
      expect(@pxxbuckets.value(0.95)).to eq(10)
    end

    it 'finds the pxx value for scattered data points' do
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(7)
      @pxxbuckets.increment(12)
      @pxxbuckets.increment(14)
      @pxxbuckets.increment(18)
      @pxxbuckets.increment(25)
      expect(@pxxbuckets.value(0.50)).to eq(10)
      expect(@pxxbuckets.value(0.75)).to eq(10)
      expect(@pxxbuckets.value(0.95)).to eq(20)
    end
  end

  context :with_floats do
    before :each do
      @ranges = {
        10 => 0.1,
        20 => 0.2,
        40 => 0.5,
        100 => 1
      }

      @pxxbuckets = PxxBuckets.new({ :ranges => @ranges, :pxx_keys => [ 75, 95, 99 ] })
    end

    it 'finds the pxx value for scattered data points' do
      0.upto(99) do |i|
        @pxxbuckets.increment(i+0.1)
      end
      expect(@pxxbuckets.value(0.95)).to eq(94)
      expect(@pxxbuckets.value(0.99)).to eq(98)
    end
  end

end
