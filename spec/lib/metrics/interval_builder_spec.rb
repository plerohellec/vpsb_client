require 'spec_helper'

module VpsbClient
  module Metrics
    support_dir = File.join(File.dirname(__FILE__), '../..', 'support/')

    OLDEST_TIME_IN_LOGFILES = Time.new(2014,9,20,0,0,0)
    NEWEST_TIME_IN_LOGFILES = Time.new(2014,9,21,13,56,0)

    describe IntervalBuilder do
      before :each do
        @sar_dir = "#{support_dir}/sarfiles/formatted"
        @timing_dir = "#{support_dir}/timingfiles"
        @length = 3600
        allow(Time).to receive(:now).and_return(NEWEST_TIME_IN_LOGFILES + @length)
      end

      context 'with aligned pole time' do
        before :each do
          aligned_pole_time = OLDEST_TIME_IN_LOGFILES - 12*3600
          @builder = IntervalBuilder.new(@sar_dir, @timing_dir, aligned_pole_time, @length)
        end

        it 'should yield once per full hour' do
          expected_num_intervals = (NEWEST_TIME_IN_LOGFILES - OLDEST_TIME_IN_LOGFILES) / @length
          expect { |b| @builder.each(&b) }.to yield_control.at_least(expected_num_intervals)
        end

        describe 'first interval' do
          it 'is the most recent' do
            interval_enum = @builder.each
            expected_start_time = lower_time_boundary(NEWEST_TIME_IN_LOGFILES, @length)
            expect(interval_enum.next[:started_at]).to eq(expected_start_time)
            expect(interval_enum.next[:started_at]).to eq(expected_start_time - @length)
          end

          it 'has the requested length' do
            i = @builder.each.first
            expect(i[:duration_seconds]).to eq(@length)
          end

          it 'has the right averaged timing' do
            i = @builder.each.first
            expect(i[:started_at]).to eq(lower_time_boundary(NEWEST_TIME_IN_LOGFILES, @length))
            expect(i[:resptime_total_ms]).to eq(29.5)
          end

          it 'as the right p95 cpu idle' do
            i = @builder.each.first
            expect(i[:p99_cpuidle_pct]).to eq(88.0)
          end
        end

        describe 'last interval' do
          it 'starts at the oldest data point' do
            last_interval = nil
            @builder.each do |i|
              last_interval = i
            end
            expect(last_interval[:started_at]).to eq(OLDEST_TIME_IN_LOGFILES)
            expect(last_interval[:duration_seconds]).to eq(@length)
          end
        end
      end

      context 'with unaligned pole time' do
        before :each do
          @offset = 60
          unaligned_pole_time = OLDEST_TIME_IN_LOGFILES - 12*3600 + @offset
          @builder = IntervalBuilder.new(@sar_dir, @timing_dir, unaligned_pole_time, @length)
        end

        describe 'first interval' do
          it 'start with on offset start_time' do
            i = @builder.each.first
            expected_start_time = lower_time_boundary(NEWEST_TIME_IN_LOGFILES, @length) + @offset
            expect(i[:started_at]).to eq(expected_start_time)
          end
        end
      end

      def lower_time_boundary(t, len)
        Time.at((t.to_i / len) * len)
      end
    end
  end
end

