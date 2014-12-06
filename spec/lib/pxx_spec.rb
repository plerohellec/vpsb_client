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
    @pxxbuckets.buckets.size.should == 4
    @pxxbuckets.ary[0].should == 0
    @pxxbuckets.ary[1].should == 5
    @pxxbuckets.ary[2].should == 10
    @pxxbuckets.ary[3].should == 20
  end

  it 'initializes bucket values to 0' do
    @pxxbuckets.buckets.values.should == [0, 0, 0, 0]
  end

  it 'sets bucket keys to ranges start' do
    @pxxbuckets.buckets.keys.should == [0, 5, 10, 20]
  end

  describe :find_bucket_key do
    it 'returns bucket indexes' do
      @pxxbuckets.find_bucket_key(0).should == 0
      @pxxbuckets.find_bucket_key(5).should == 1
      @pxxbuckets.find_bucket_key(15).should == 2
      @pxxbuckets.find_bucket_key(1000).should == 3
    end
  end

  it 'places 0 in first bucket' do
    @pxxbuckets.increment(0)
    @pxxbuckets.buckets[0].should == 1
    @pxxbuckets.buckets[5].should == 0
    @pxxbuckets.buckets[10].should == 0
    @pxxbuckets.buckets[20].should == 0
  end

  it 'places 15 in 3rd bucket' do
    @pxxbuckets.increment(15)
    @pxxbuckets.buckets[0].should == 0
    @pxxbuckets.buckets[5].should == 0
    @pxxbuckets.buckets[10].should == 1
    @pxxbuckets.buckets[20].should == 0
  end

  it 'places 1000 in last bucket' do
    @pxxbuckets.increment(1000)
    @pxxbuckets.buckets[0].should == 0
    @pxxbuckets.buckets[5].should == 0
    @pxxbuckets.buckets[10].should == 0
    @pxxbuckets.buckets[20].should == 1
  end

  describe :value do
    it 'finds the pXX value for single high item' do
      @pxxbuckets.increment(1000)
      @pxxbuckets.value(0.50).should == 20
      @pxxbuckets.value(0.75).should == 20
      @pxxbuckets.value(0.95).should == 20
    end

    it 'finds the pXX value for single low item' do
      @pxxbuckets.increment(2)
      @pxxbuckets.value(0.50).should == 0
      @pxxbuckets.value(0.75).should == 0
      @pxxbuckets.value(0.95).should == 0
    end

    it 'finds the pxx value for low majority' do
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(10)
      @pxxbuckets.value(0.50).should == 0
      @pxxbuckets.value(0.75).should == 10
      @pxxbuckets.value(0.95).should == 10
    end

    it 'finds the pxx value for scattered data points' do
      @pxxbuckets.increment(2)
      @pxxbuckets.increment(7)
      @pxxbuckets.increment(12)
      @pxxbuckets.increment(14)
      @pxxbuckets.increment(18)
      @pxxbuckets.increment(25)
      @pxxbuckets.value(0.50).should == 10
      @pxxbuckets.value(0.75).should == 10
      @pxxbuckets.value(0.95).should == 20
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
      @pxxbuckets.value(0.95).should == 94
      @pxxbuckets.value(0.99).should == 98
    end
  end

end
