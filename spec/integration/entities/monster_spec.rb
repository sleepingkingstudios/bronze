# frozen_string_literal: true

require 'support/entities/monster'

RSpec.describe Spec::Monster do
  subject(:monster) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      name:  nil,
      level: nil
    }
  end
  let(:initial_attributes) do
    {
      name:  'Rogue Bull',
      level: 5
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    describe 'with :army' do
      it { expect(described_class.attributes[:army]).to be nil }
    end

    describe 'with :level' do
      let(:metadata) { described_class.attributes[:level] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :level }

      it { expect(metadata.type).to be Integer }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }
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
    end

    describe 'with :uuid' do
      let(:metadata) { described_class.attributes[:uuid] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :uuid }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be true }

      it { expect(metadata.default).to be =~ /\A[0-9a-f\-]{36}\z/ }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be true }

      it { expect(metadata.read_only?).to be true }
    end
  end

  describe '#assign_attributes' do
    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { monster.assign_attributes({}) }
          .not_to change(monster, :attributes)
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'name'  => 'Rotscale',
          'level' => 30
        }
      end
      let(:expected) do
        {
          uuid:  monster.uuid,
          name:  'Rotscale',
          level: 30
        }
      end

      it 'should update the attributes' do
        expect { monster.assign_attributes(attributes) }
          .to change(monster, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          name:  'Rotscale',
          level: 30
        }
      end
      let(:expected) do
        {
          uuid:  monster.uuid,
          name:  'Rotscale',
          level: 30
        }
      end

      it 'should update the attributes' do
        expect { monster.assign_attributes(attributes) }
          .to change(monster, :attributes)
          .to be == expected
      end
    end
  end

  describe '#attribute?' do
    it { expect(monster.attribute? :army).to be false }

    it { expect(monster.attribute? :level).to be true }

    it { expect(monster.attribute? :name).to be true }

    it { expect(monster.attribute? :uuid).to be true }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(uuid: monster.uuid)
    end

    it { expect(monster.attributes).to be == expected }
  end

  describe '#attributes=' do
    describe 'with an empty hash' do
      let(:expected) do
        {
          uuid:  monster.uuid,
          name:  nil,
          level: nil
        }
      end

      it 'should update the attributes' do
        expect { monster.attributes = {} }
          .to change(monster, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'name'  => 'Rotscale',
          'level' => 30
        }
      end
      let(:expected) do
        {
          uuid:  monster.uuid,
          name:  'Rotscale',
          level: 30
        }
      end

      it 'should update the attributes' do
        expect { monster.attributes = attributes }
          .to change(monster, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          name:  'Rotscale',
          level: 30
        }
      end
      let(:expected) do
        {
          uuid:  monster.uuid,
          name:  'Rotscale',
          level: 30
        }
      end

      it 'should update the attributes' do
        expect { monster.attributes = attributes }
          .to change(monster, :attributes)
          .to be == expected
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::Monster ' \
        "uuid: #{monster.uuid.inspect}, " \
        "name: #{monster.name.inspect}, " \
        "level: #{monster.level.inspect}>"
    end

    it { expect(monster.inspect).to be == expected }
  end

  describe '#level' do
    include_examples 'should have reader',
      :level,
      -> { be == initial_attributes[:level] }
  end

  describe '#level=' do
    include_examples 'should have writer', :level=

    it 'should update the mana cost' do
      expect { monster.level = 24 }
        .to change(monster, :level)
        .to be == 24
    end
  end

  describe '#name' do
    include_examples 'should have reader',
      :name,
      -> { be == initial_attributes[:name] }
  end

  describe '#name=' do
    let(:name) { 'Dying Nightmare' }

    include_examples 'should have writer', :name=

    it 'should update the name' do
      expect { monster.name = name }
        .to change(monster, :name)
        .to be == name
    end
  end

  describe '#uuid' do
    include_examples 'should have reader',
      :uuid,
      -> { be =~ /\A[0-9a-f\-]{36}\z/ }
  end

  describe '#uuid=' do
    include_examples 'should have private writer', :uuid=
  end
end
