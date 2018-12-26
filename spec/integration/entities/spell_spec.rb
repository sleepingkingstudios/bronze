# frozen_string_literal: true

require 'support/entities/spell'

RSpec.describe Spec::Spell do
  subject(:spell) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      name:      nil,
      mana_cost: nil
    }
  end
  let(:initial_attributes) do
    {
      name:      'Magic Missile',
      mana_cost: 1
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :element' do
      it { expect(described_class.attributes[:element]).to be nil }
    end

    describe 'with :hex' do
      let(:metadata) { described_class.attributes[:hex] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :hex }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be true }

      it { expect(metadata.default).to be =~ /\A[0-9a-f]{16}\z/ }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be true }

      it { expect(metadata.read_only?).to be true }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :mana_cost' do
      let(:metadata) { described_class.attributes[:mana_cost] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :mana_cost }

      it { expect(metadata.type).to be Integer }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :name' do
      let(:metadata) { described_class.attributes[:name] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :name }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end
  end

  describe '#assign_attributes' do
    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { spell.assign_attributes({}) }
          .not_to change(spell, :attributes)
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'name'      => 'Fireball',
          'mana_cost' => 3
        }
      end
      let(:expected) do
        {
          hex:       spell.hex,
          name:      'Fireball',
          mana_cost: 3
        }
      end

      it 'should update the attributes' do
        expect { spell.assign_attributes(attributes) }
          .to change(spell, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          name:      'Fireball',
          mana_cost: 3
        }
      end
      let(:expected) do
        {
          hex:       spell.hex,
          name:      'Fireball',
          mana_cost: 3
        }
      end

      it 'should update the attributes' do
        expect { spell.assign_attributes(attributes) }
          .to change(spell, :attributes)
          .to be == expected
      end
    end
  end

  describe '#attribute?' do
    it { expect(spell.attribute? :element).to be false }

    it { expect(spell.attribute? :hex).to be true }

    it { expect(spell.attribute? :mana_cost).to be true }

    it { expect(spell.attribute? :name).to be true }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(hex: spell.hex)
    end

    it { expect(spell.attributes).to be == expected }
  end

  describe '#attributes=' do
    describe 'with an empty hash' do
      let(:expected) do
        {
          hex:       spell.hex,
          name:      nil,
          mana_cost: nil
        }
      end

      it 'should update the attributes' do
        expect { spell.attributes = {} }
          .to change(spell, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'name'      => 'Fireball',
          'mana_cost' => 3
        }
      end
      let(:expected) do
        {
          hex:       spell.hex,
          name:      'Fireball',
          mana_cost: 3
        }
      end

      it 'should update the attributes' do
        expect { spell.attributes = attributes }
          .to change(spell, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          name:      'Fireball',
          mana_cost: 3
        }
      end
      let(:expected) do
        {
          hex:       spell.hex,
          name:      'Fireball',
          mana_cost: 3
        }
      end

      it 'should update the attributes' do
        expect { spell.attributes = attributes }
          .to change(spell, :attributes)
          .to be == expected
      end
    end
  end

  describe '#hex' do
    include_examples 'should have reader',
      :hex,
      -> { be =~ /\A[0-9a-f]{16}\z/ }
  end

  describe '#hex=' do
    include_examples 'should have private writer', :hex=
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::Spell ' \
        "hex: #{spell.hex.inspect}, " \
        "name: #{spell.name.inspect}, " \
        "mana_cost: #{spell.mana_cost.inspect}>"
    end

    it { expect(spell.inspect).to be == expected }
  end

  describe '#mana_cost' do
    include_examples 'should have reader',
      :mana_cost,
      -> { be == initial_attributes[:mana_cost] }
  end

  describe '#mana_cost=' do
    include_examples 'should have writer', :mana_cost=

    it 'should update the mana cost' do
      expect { spell.mana_cost = 3 }
        .to change(spell, :mana_cost)
        .to be == 3
    end
  end

  describe '#name' do
    include_examples 'should have reader',
      :name,
      -> { be == initial_attributes[:name] }
  end

  describe '#name=' do
    let(:name) { 'Invoked Apocalypse' }

    include_examples 'should have writer', :name=

    it 'should update the name' do
      expect { spell.name = name }
        .to change(spell, :name)
        .to be == name
    end
  end
end
