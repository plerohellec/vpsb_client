require 'spec_helper'

module VpsbClient
  module Builders
    support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

    describe MemoryParser do
      it 'finds the amount of memory available in the system' do
        mp = MemoryParser.new
        mp.parse
        expect(mp.used).to be_an_instance_of(Fixnum)
        expect(mp.free).to be_an_instance_of(Fixnum)
        expect(mp.total).to be_an_instance_of(Fixnum)
      end
    end

    describe UnameParser do
      it 'finds the kernel version' do
        mp = UnameParser.new
        mp.parse
        expect(mp.kernel).to match(/^\d\.\d+\.\d+$/)
      end
    end

    describe CpuinfoParser do
      before :each do
        @mp = CpuinfoParser.new
        @mp.parse
      end

      it 'finds the model and number of processors' do
        expect(@mp.model).to match(/^.*CPU.*GHz$/)
        expect(@mp.num).to be_an_instance_of(Fixnum)
      end

      it 'finds the cpu speed' do
        expect(@mp.mhz).to be_an_instance_of(Fixnum)
      end
    end

    describe IssueParser do
      it 'finds the linux release' do
        mp = IssueParser.new
        mp.parse
        expect(mp.os).to be_a(String)
        expect(mp.os.size).to be > 0
      end
    end
  end
end

