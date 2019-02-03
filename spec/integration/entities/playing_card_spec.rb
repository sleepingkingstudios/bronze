# frozen_string_literal: true

require 'support/entities/playing_card'
require 'support/examples/entity_examples'

RSpec.describe Spec::PlayingCard do
  include Spec::Support::Examples::EntityExamples

  subject(:playing_card) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      suit:  nil,
      value: nil
    }
  end
  let(:initial_attributes) do
    {
      suit:  'spades',
      value: 1
    }
  end
  let(:expected_attributes) do
    default_attributes.merge(initial_attributes)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  include_examples 'should define attribute', :suit, String, read_only: true

  include_examples 'should define attribute', :value, Integer, read_only: true

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :arcana' do
      it { expect(described_class.attributes[:arcana]).to be nil }
    end
  end

  describe '#assign_attributes' do
    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { playing_card.assign_attributes({}) }
          .not_to change(playing_card, :attributes)
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'suit'  => 'hearts',
          'value' => 12
        }
      end

      it 'should not change the attributes' do
        expect { playing_card.assign_attributes(attributes) }
          .not_to change(playing_card, :attributes)
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          suit:  'hearts',
          value: 12
        }
      end

      it 'should not change the attributes' do
        expect { playing_card.assign_attributes(attributes) }
          .not_to change(playing_card, :attributes)
      end
    end
  end

  describe '#attribute?' do
    it { expect(playing_card.attribute? :arcana).to be false }
  end

  describe '#attributes' do
    it 'should return the attributes' do
      expect(playing_card.attributes).to match_attributes expected_attributes
    end
  end

  describe '#attributes=' do
    describe 'with an empty hash' do
      let(:expected) do
        {
          suit:  nil,
          value: nil
        }
      end

      it 'should update the attributes' do
        expect { playing_card.attributes = {} }
          .to change(playing_card, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'suit'  => 'hearts',
          'value' => 12
        }
      end
      let(:expected) do
        {
          suit:  'hearts',
          value: 12
        }
      end

      it 'should update the attributes' do
        expect { playing_card.attributes = attributes }
          .to change(playing_card, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          suit:  'hearts',
          value: 12
        }
      end
      let(:expected) do
        {
          suit:  'hearts',
          value: 12
        }
      end

      it 'should update the attributes' do
        expect { playing_card.attributes = attributes }
          .to change(playing_card, :attributes)
          .to be == expected
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::PlayingCard ' \
        "suit: #{playing_card.suit.inspect}, " \
        "value: #{playing_card.value.inspect}>"
    end

    it { expect(playing_card.inspect).to be == expected }
  end
end
