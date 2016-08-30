# spec/patina/collections/simple/criteria/limit_criterion_spec.rb

require 'patina/collections/simple/criteria/limit_criterion'

RSpec.describe Patina::Collections::Simple::Criteria::LimitCriterion do
  let(:count)    { 3 }
  let(:instance) { described_class.new count }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    shared_context 'when many items are defined for the data' do
      let(:data) do
        [
          {
            :id     => '1',
            :title  => 'The Fellowship of the Ring',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '2',
            :title  => 'The Two Towers',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '3',
            :title  => 'The Return of the King',
            :author => 'J.R.R. Tolkien'
          }, # end hash
          {
            :id     => '4',
            :title  => 'A Princess of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '5',
            :title  => 'The Gods of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
          {
            :id     => '6',
            :title  => 'The Warlord of Mars',
            :author => 'Edgar Rice Burroughs'
          }, # end hash
        ] # end array
      end # let
    end # shared_context

    let(:data) { [] }

    it { expect(instance).to respond_to(:call).with(1).argument }

    it { expect(instance.call data).to be == [] }

    wrap_context 'when many items are defined for the data' do
      let(:expected) do
        data[0...count]
      end # let

      describe 'with a limit of 0' do
        let(:count) { 0 }

        it { expect(instance.call data).to be == [] }
      end # describe

      describe 'with a limit of 1' do
        let(:count) { 1 }

        it { expect(instance.call data).to be == expected }
      end # describe

      describe 'with a limit of 3' do
        let(:count) { 3 }

        it { expect(instance.call data).to be == expected }
      end # describe

      describe 'with a limit of 6' do
        let(:count) { 6 }

        it { expect(instance.call data).to be == expected }
      end # describe

      describe 'with a limit of 10' do
        let(:count) { 10 }

        it { expect(instance.call data).to be == expected }
      end # describe
    end # wrap_context
  end # describe

  describe '#count' do
    include_examples 'should have reader', :count, ->() { be == count }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, :limit
  end # describe
end # describe
