require 'spec_helper'

module VpsbClient

  module Datafiles
    data_dir = File.join(File.dirname(__FILE__), '..', 'support/sarfiles')

     class TestSadf
      SADF = '/usr/bin/sadf'

      def self.run(src, dest)
        cmd = "touch #{dest}"
        ret = system cmd
        raise VpsbClient::Datafiles::SarManager::SadfError, "\"#{cmd}\" failed" unless ret
      end
    end

    describe SarManager do
      before :each do
        @orig_dir = "#{data_dir}/orig"
        @target_dir = "#{data_dir}/dest"
        @manager = SarManager.new(@orig_dir, @target_dir, TestSadf)
        allow(Time).to receive(:now).and_return(Time.new(2014,9,21,16,0,1,'-08:00'))
      end

      after :each do
        FileUtils.rm_rf(@target_dir)
      end

      it 'raises an error if the orig dir does not exist' do
        expect{SarManager.new('blah', @target_dir)}.to raise_error(SarManager::NotFoundError)
      end

      it 'creates the target directory' do
        @manager.run
        expect(File.directory?(@target_dir)).to be true
      end

      it 'generates daily formatted files' do
        @manager.run
        sa_files = [ 'sa18', 'sa19', 'sa20', 'sa21' ]
        formatted_files = sa_files.map { |f| "#{@target_dir}/formatted_#{f}" }
        formatted_files.each do |f|
          expect(File.exist?(f)).to be true
        end
      end

      it 'replaces current day formatted file if it exists' do
        system "mkdir #{@target_dir}"
        system "echo \"hello\" > #{@target_dir}/formatted_sa20140921"
        @manager.run
        lines = File.readlines("#{@target_dir}/formatted_sa20140921")
        expect(lines.first).not_to match(/hello/)
      end
    end
  end
end
