require 'spec_helper'

module VpsbClient
  module Client
    describe UploadMetrics do
      before :each do
        config = { }
        @manager = Manager.new('fake_path', Logger.new(STDOUT))
        allow(@manager).to receive(:prepare_logfiles)
        allow(@manager).to receive(:enabled?).and_return(true)
        allow(@manager).to receive(:config).and_return(config)
      end

      it 'upload metrics for all lengths' do
        trial = double('trial')
        expect(@manager).to receive(:upload_for_interval_length).with(trial, 600).and_return([])
        expect(@manager).to receive(:upload_for_interval_length).with(trial, 3600).and_return([])
        expect(@manager).to receive(:upload_for_interval_length).with(trial, 86400).and_return([])
        @manager.upload_metrics(trial)
      end
    end
  end
end