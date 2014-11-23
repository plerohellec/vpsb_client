require 'spec_helper'

module VpsbClient
  module Metrics
    describe IntervalConfig do
      describe :length do
        it 'returns the provided length' do
          ic = IntervalConfig.new(nil, 3600)
          expect(ic.length).to eq(3600)
        end
      end

      describe :min_end_time do
        it 'is min_start_time + length' do
          t = Time.new(2014, 11, 15, 20, 0, 0)
          ic = IntervalConfig.new(t, 3600)
          expect(ic.min_end_time).to eq(ic.min_start_time + 3600)
        end
      end

      context 'with force' do
        before :each do
          @forced_start_time = Time.new(2014, 11, 15, 20, 0, 0)
        end

        context 'with short interval length' do
          before :each do
            @length = 60
            @ic = IntervalConfig.new(@forced_start_time, @length, force: true)
          end

          it 'aligned? is false' do
            expect(@ic.aligned?).to eq(false)
          end

          it 'min_start_time is forced_start_time' do
            expect(@ic.min_start_time).to eq(@forced_start_time)
          end
        end

        context 'with long interval length' do
          before :each do
            @length = 604800
            @ic = IntervalConfig.new(@forced_start_time, @length, force: true)
          end

          it 'aligned? is false' do
            expect(@ic.aligned?).to eq(false)
          end

          it 'min_start_time is forced_start_time' do
            expect(@ic.min_start_time).to eq(@forced_start_time)
          end
        end
      end

      context 'without force' do
        before :each do
          @forced_start_time = nil
          @fallback_start_time = Time.new(2014, 11, 15, 20, 0, 0)
        end

        context 'with short interval length' do
          before :each do
            @length = 60
            @ic = IntervalConfig.new(@fallback_start_time, @length)
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
            @ic = IntervalConfig.new(@fallback_start_time, @length)
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
