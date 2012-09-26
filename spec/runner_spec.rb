require_relative 'spec_helper'
require 'tmpdir'

describe Runner do

  before :each do
    context = double('context')
    Context.stub(:instance).and_return(context)
  end

  describe '.run' do
    context 'when base_dir does not exist' do
      it 'make base_dir' do
        Context.instance.stub(:processes).and_return(1)
        Dir.mktmpdir do |dir|
          src = double('src')
          src.stub(:repos).and_return([:src, :repos])
          Runner.stub(:src).and_return(src)
          Runner.stub(:base_dir).and_return(File.join(dir, 'non/exisnting/directory'))
          Runner.stub(:mirror)
          Runner.run
          expect(File.directory? Runner.base_dir).to be_true
        end
      end
    end
  end

end
