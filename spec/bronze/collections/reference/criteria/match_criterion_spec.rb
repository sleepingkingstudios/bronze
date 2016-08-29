# spec/bronze/collections/reference/criteria/match_criterion_spec.rb

require 'bronze/collections/reference/criteria/match_criterion'

RSpec.describe Spec::Reference::Criteria::MatchCriterion do
  let(:selector) { { :id => '0' } }
  let(:instance) { described_class.new selector }

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
        data.select { |hsh| hsh >= selector }
      end # let

      describe 'with a selector that does not match any items' do
        let(:selector) { { :id => '0' } }

        it { expect(instance.call data).to be == [] }
      end # describe

      describe 'with a selector that matches one item' do
        let(:selector) { { :id => '1' } }

        it { expect(instance.call data).to be == expected }
      end # describe

      describe 'with a selector that matches many items' do
        let(:selector) { { :author => 'J.R.R. Tolkien' } }

        it { expect(instance.call data).to be == expected }
      end # describe

      describe 'with a multi-attribute selector' do
        let(:selector) do
          { :title => 'A Princess of Mars', :author => 'Edgar Rice Burroughs' }
        end # let

        it { expect(instance.call data).to be == expected }
      end # describe
    end # wrap_context
  end # describe

  describe '#selector' do
    include_examples 'should have reader', :selector, ->() { be == selector }
  end # describe
end # describe
