require 'spec_helper'
require "#{File.expand_path('../../..',  __FILE__)}/lib/vpsb_client/datafiles/logfile_decompressor"

module VpsbClient

  module Datafiles
    data_dir = File.join(File.dirname(__FILE__), '..', 'support/timingfiles')

    describe LogfileDecompressor do
      before :all do
        @orig_dir = data_dir
        @target_dir = data_dir
      end

      context 'no rotation id limit' do
        before :each do
          @manager = LogfileDecompressor.new(@orig_dir, @target_dir, 'timings')
        end

        after :each do
          File.unlink("#{@target_dir}/timings.log.2")
          File.unlink("#{@target_dir}/timings.log.3")
        end

        it 'unzips files with .gz extension' do
          @manager.run
          expect(File.exist?("#{@target_dir}/timings.log.2")).to be_true
          expect(File.exist?("#{@target_dir}/timings.log.3")).to be_true
        end

        it 'only unzips files with specified prefix' do
          @manager.run
          expect(File.exist?("#{@target_dir}/other.log.2")).to be_false
        end
      end

      context 'with rotation id limit' do
        before :each do
          @manager = LogfileDecompressor.new(@orig_dir, @target_dir, 'timings', :max_rotation_id => 2)
        end

        after :each do
          File.unlink("#{@target_dir}/timings.log.2")
        end

        it 'unzips only files below limit' do
          @manager.run
          expect(File.exist?("#{@target_dir}/timings.log.2")).to be_true
          expect(File.exist?("#{@target_dir}/timings.log.3")).to be_false
        end
      end
    end
  end
end