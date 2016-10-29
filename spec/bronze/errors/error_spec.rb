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

  describe '#==' do
    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(instance == nil).to be false }
    end # describe
    # rubocop:enable Style/NilComparison

    describe 'with an object' do
      it { expect(instance == Object.new).to be false }
    end # describe

    describe 'with an error with non-matching nesting' do
      let(:other) do
        described_class.new([:object], type, params)
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with an error with non-matching params' do
      let(:other) do
        described_class.new(nesting, type, [:at, :'451_degrees'])
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with an error with non-matching type' do
      let(:other) do
        described_class.new(nesting, :undergoing_combustion, params)
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a matching error' do
      let(:other) { described_class.new nesting, type, params }

      it { expect(instance == other).to be true }
    end # describe
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

  describe '#with_nesting' do
    let(:other_nesting) { [:posts, 0, :subtitle] }

    it { expect(instance).to respond_to(:with_nesting).with(1).argument }

    it 'should return a copy of the error' do
      error = instance.with_nesting other_nesting

      expect(error.nesting).to be == other_nesting
    end # it

    it 'should not change the error' do
      expect { instance.with_nesting other_nesting }.
        not_to change(instance, :nesting)
    end # it
  end # describe
end # describe
