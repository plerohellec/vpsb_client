require 'spec_helper'

module VpsbClient
  module Builders
    support_dir = File.join(File.dirname(__FILE__), '..', 'support/')

    describe MetricsInterval do
      before :each do
        @sar_dir = "#{support_dir}/sarfiles/formatted"
        @timing_dir = "#{support_dir}/timingfiles"
        @builder = MetricsInterval.new(@sar_dir, @timing_dir, Time.new(2014,9,19,12,0,0), 3600)
        allow(Time).to receive(:now).and_return(Time.new(2014,9,21,14,0,1))
      end

      it 'should yield 37 times' do
        expect { |b| @builder.each(&b) }.to yield_control.at_least(37)
      end

      context 'first interval' do
        it 'is the most recent' do
          interval_enum = @builder.each
          expect(interval_enum.next[:start_time]).to eq(Time.new(2014,9,21,13,0,0))
          expect(interval_enum.next[:start_time]).to eq(Time.new(2014,9,21,12,0,0))
        end

        it 'has the requested length' do
          i = @builder.each.first
          expect(i[:duration_seconds]).to eq(3600)
        end

        it 'has the right averaged timing' do
          i = @builder.each.first
          expect(i[:start_time]).to eq(Time.new(2014,9,21,13,0,0))
          expect(i[:resptime_total_ms]).to eq(29.5)
        end

        it 'as the right p95 cpu idle' do
          i = @builder.each.first
          expect(i[:p99_cpuidle_pct]).to eq(88.0)
        end
      end

      context 'last interval' do
        it 'starts at the oldest data point' do
          last_interval = nil
          @builder.each do |i|
            last_interval = i
          end
          expect(last_interval[:start_time]).to eq(Time.new(2014,9,20,0,0,0))
          expect(last_interval[:duration_seconds]).to eq(3600)
        end
      end
    end
  end
end

