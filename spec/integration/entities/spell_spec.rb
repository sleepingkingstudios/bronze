# frozen_string_literal: true

require 'support/entities/spell'
require 'support/examples/entity_examples'

RSpec.describe Spec::Spell do
  include Spec::Support::Examples::EntityExamples

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
  let(:expected_attributes) do
    default_attributes
      .merge(initial_attributes)
      .merge(hex: be =~ /\A[0-9a-f]{16}\z/)
  end

  include_examples 'should define primary key',
    :hex,
    String,
    default: -> { be =~ /\A[0-9a-f]{16}\z/ }

  include_examples 'should define attribute', :name, String

  include_examples 'should define attribute', :mana_cost, Integer

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :element' do
      it { expect(described_class.attributes[:element]).to be nil }
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
  end

  describe '#attributes' do
    let(:expected) do
      expected_attributes.merge(hex: spell.hex)
    end

    it { expect(spell.attributes).to match_attributes expected }
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

  describe '#inspect' do
    let(:expected) do
      '#<Spec::Spell ' \
        "hex: #{spell.hex.inspect}, " \
        "name: #{spell.name.inspect}, " \
        "mana_cost: #{spell.mana_cost.inspect}>"
    end

    it { expect(spell.inspect).to be == expected }
  end
end
