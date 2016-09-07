# spec/bronze/errors/error_spec.rb

require 'bronze/errors/error'

RSpec.describe Bronze::Errors::Error do
  let(:nesting)  { [] }
  let(:type)     { :is_currently_on_fire }
  let(:params)   { [] }
  let(:instance) { described_class.new nesting, type, params }

  describe '::new' do
    it 'should be constructible' do
      expect(described_class).to be_constructible.with(3).arguments
    end # it
  end # describe

  describe '#nesting' do
    include_examples 'should have reader', :nesting, ->() { be == nesting }
  end # describe

  describe '#params' do
    include_examples 'should have reader', :params, ->() { be == params }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, ->() { be == type }
  end # describe
end # describe
