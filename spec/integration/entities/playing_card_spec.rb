# frozen_string_literal: true

require 'support/entities/playing_card'

RSpec.describe Spec::PlayingCard do
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

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :arcana' do
      it { expect(described_class.attributes[:arcana]).to be nil }
    end

    describe 'with :suit' do
      let(:metadata) { described_class.attributes[:suit] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :suit }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be true }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :value' do
      let(:metadata) { described_class.attributes[:value] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :value }

      it { expect(metadata.type).to be Integer }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be true }

      it { expect(metadata.transform?).to be false }
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

    it { expect(playing_card.attribute? :suit).to be true }

    it { expect(playing_card.attribute? :value).to be true }
  end

  describe '#attributes' do
    let(:expected) { default_attributes.merge(initial_attributes) }

    it { expect(playing_card.attributes).to be == expected }
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

  describe '#suit' do
    include_examples 'should have reader',
      :suit,
      -> { be == initial_attributes[:suit] }
  end

  describe '#suit=' do
    include_examples 'should have private writer', :suit=
  end

  describe '#value' do
    include_examples 'should have reader',
      :value,
      -> { be == initial_attributes[:value] }
  end

  describe '#value=' do
    include_examples 'should have private writer', :value=
  end
end
