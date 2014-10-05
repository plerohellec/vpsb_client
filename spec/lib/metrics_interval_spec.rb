require 'spec_helper'

module VpsbClient
  module Builders
    support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

    describe MetricsInterval do
      before :each do
        @sar_dir = "#{support_dir}/sarfiles/formatted"
        @timing_dir = "#{support_dir}/timingfiles"
        @builder = MetricsInterval.new(@sar_dir, @timing_dir, Time.new(2014,9,20,12,0,0), 3600)
        allow(Time).to receive(:now).and_return(Time.new(2014,9,21,16,0,1))
      end

      it 'should yield 27 times' do
        expect { |b| @builder.each(&b) }.to yield_control.at_least(27)
      end

      context 'first interval' do
        it 'goes in descending order' do
          interval_enum = @builder.each
          expect(interval_enum.next[:start_time]).to eq(Time.new(2014,9,21,15,0,0))
          expect(interval_enum.next[:start_time]).to eq(Time.new(2014,9,21,14,0,0))
        end
      end
    end
  end
end

