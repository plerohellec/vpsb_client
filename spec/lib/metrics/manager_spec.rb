require 'spec_helper'

module VpsbClient
  module Metrics
    describe Manager do
      before :each do
        @min_start_time = Time.new(2014, 11, 15, 20, 0, 0)
        @length = 3600
        @builder = double('builder')
        @uploader = double('uploader')
        @interval_config = double('config')
        allow(@interval_config).to receive(:length).and_return(@length)
        allow(@interval_config).to receive(:min_start_time).and_return(@min_start_time)
        allow(@interval_config).to receive(:min_end_time).and_return(@min_start_time + @length)

        @manager = Manager.new(@builder, @uploader, @interval_config)
      end

      describe :run do
        it 'uploads each builder metric' do
          metric = double('metric')
          allow(metric).to receive(:[]).with(:started_at).and_return(@min_start_time)
          expect(@builder).to receive(:each).and_yield(metric)
          expect(@uploader).to receive(:upload).with(metric).once

          @manager.run
        end

        it 'stops at the first metric with start_time lower than min_start_time' do
          metric1 = double('metric1')
          allow(metric1).to receive(:[]).with(:started_at).and_return(@min_start_time)

          metric2 = double('metric2')
          allow(metric2).to receive(:[]).with(:started_at).and_return(@min_start_time - 1)
          expect(@builder).to receive(:each).and_yield(metric1).and_yield(metric2)
          expect(@uploader).to receive(:upload).with(metric1).once
          expect(@uploader).to receive(:upload).with(metric2).never

          @manager.run
        end
      end

      describe :created_metric_ids do
        it 'contains the ids of the new metrics' do
          metric1 = double('metric1')
          allow(metric1).to receive(:[]).with(:started_at).and_return(@min_start_time + 1)

          metric2 = double('metric2')
          allow(metric2).to receive(:[]).with(:started_at).and_return(@min_start_time)
          allow(@builder).to receive(:each).and_yield(metric1).and_yield(metric2)
          allow(@uploader).to receive(:upload).with(metric1).and_return(100)
          allow(@uploader).to receive(:upload).with(metric2).and_return(101)

          @manager.run
          expect(@manager.created_metric_ids).to eq([100, 101])
        end
      end
    end
  end
end
