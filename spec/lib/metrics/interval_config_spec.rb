require 'spec_helper'

module VpsbClient
  module Metrics
    describe IntervalConfig do
      describe :length do
        it 'returns the provided length' do
          ic = IntervalConfig.new(nil, nil, 3600)
          expect(ic.length).to eq(3600)
        end
      end

      context 'with previous start time' do
        before :each do
          @previous_start_time = Time.new(2014, 11, 15, 20, 0, 0)
          @fallback_start_time = nil
        end

        context 'with short interval length' do
          before :each do
            @length = 60
            @ic = IntervalConfig.new(@fallback_start_time, @previous_start_time, @length)
          end

          it 'aligned? is false' do
            expect(@ic.aligned?).to eq(false)
          end

          it 'min_start_time is previous_start_time + length' do
            expect(@ic.min_start_time).to eq(@previous_start_time + @length)
          end
        end

        context 'with long interval length' do
          before :each do
            @length = 604800
            @ic = IntervalConfig.new(@fallback_start_time, @previous_start_time, @length)
          end

          it 'aligned? is false' do
            expect(@ic.aligned?).to eq(false)
          end

          it 'min_start_time is previous_start_time + length' do
            expect(@ic.min_start_time).to eq(@previous_start_time + @length)
          end
        end
      end

      context 'without previous start time' do
        before :each do
          @previous_start_time = nil
          @fallback_start_time = Time.new(2014, 11, 15, 20, 0, 0)
        end

        context 'with short interval length' do
          before :each do
            @length = 60
            @ic = IntervalConfig.new(@fallback_start_time, @previous_start_time, @length)
          end

          it 'aligned? is true' do
            expect(@ic.aligned?).to eq(true)
          end

          it 'min_start_time is lower aligned boundary of fallback_start_time' do
            expect(@ic.min_start_time).to eq(lower_time_boundary(@fallback_start_time, @length))
          end
        end

        context 'with long interval length' do
          before :each do
            @length = 604800
            @ic = IntervalConfig.new(@fallback_start_time, @previous_start_time, @length)
          end

          it 'aligned? is false' do
            expect(@ic.aligned?).to eq(false)
          end

          it 'min_start_time is fallback_start_time' do
            expect(@ic.min_start_time).to eq(@fallback_start_time)
          end
        end
      end

      def lower_time_boundary(t, len)
        Time.at((t.to_i / len) * len)
      end
    end
  end
end
