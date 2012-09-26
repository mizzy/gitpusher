require_relative 'spec_helper'
require 'tempfile'
require 'pathname'

describe GitPusher::Config do

  subject { Context.instance.config }

  describe '.load' do
    context 'with base_dir including tilda in config file' do
      Tempfile.open 'gitpusher' do |file|
        file.write ':base_dir: ~/var/repo'
        file.rewind
        GitPusher::Config.load({ config: file.path })
        it 'ensure base_dir absolute path' do
          expect(Pathname(subject[:base_dir]).absolute?).to be_true
        end
      end
    end

    context 'with base_dir including relative path in config file' do
      Tempfile.open 'gitpusher' do |file|
        file.write ':base_dir: var/repo'
        file.rewind
        GitPusher::Config.load({ config: file.path })
        it 'ensure base_dir absolute path' do
          expect(Pathname(subject[:base_dir]).absolute?).to be_true
        end
      end
    end
  end

end
