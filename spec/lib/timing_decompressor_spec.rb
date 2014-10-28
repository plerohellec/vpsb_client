require 'spec_helper'
require "#{File.expand_path('../../..',  __FILE__)}/lib/vpsb_client/datafiles/timing_decompressor"

module VpsbClient

  module Datafiles
    data_dir = File.join(File.dirname(__FILE__), '..', 'support/timingfiles')

      describe TimingDecompressor do
        before :each do
          @orig_dir = data_dir
          @target_dir = data_dir
          @manager = TimingDecompressor.new(@orig_dir, @target_dir)
        end

        after :each do
          File.unlink("#{@target_dir}/timings.log.2")
        end

        it 'unzips files with .gz extension' do
          @manager.run
          expect(File.exist?("#{@target_dir}/timings.log.2")).to be_true
        end
    end
  end
end