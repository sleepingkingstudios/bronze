# frozen_string_literal: true

require 'support/entities/monster'

RSpec.describe Spec::Monster do
  subject(:monster) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      capture_date: nil,
      capture_odds: nil,
      design_time:  nil,
      name:         nil,
      level:        nil,
      release_date: nil,
      stats:        nil,
      type:         nil
    }
  end
  let(:initial_attributes) do
    {
      capture_odds: BigDecimal('0.05'),
      name:         'Rogue Bull',
      level:        5,
      release_date: Date.new(2005, 4, 26)
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    describe 'with :army' do
      it { expect(described_class.attributes[:army]).to be nil }
    end

    describe 'with :capture_date' do
      let(:metadata) { described_class.attributes[:capture_date] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :capture_date }

      it { expect(metadata.type).to be DateTime }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::DateTimeTransform
      end

      it { expect(metadata.transform?).to be true }
    end

    describe 'with :capture_odds' do
      let(:metadata) { described_class.attributes[:capture_odds] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :capture_odds }

      it { expect(metadata.type).to be BigDecimal }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::BigDecimalTransform
      end

      it { expect(metadata.transform?).to be true }
    end

    describe 'with :design_time' do
      let(:metadata) { described_class.attributes[:design_time] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :design_time }

      it { expect(metadata.type).to be Time }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::TimeTransform
      end

      it { expect(metadata.transform?).to be true }
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

    describe 'with :release_date' do
      let(:metadata) { described_class.attributes[:release_date] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :release_date }

      it { expect(metadata.type).to be Date }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::DateTransform
      end

      it { expect(metadata.transform?).to be true }
    end

    describe 'with :stats' do
      let(:metadata) { described_class.attributes[:stats] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :stats }

      it { expect(metadata.type).to be described_class::Stats }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a described_class::StatsTransform
      end

      it { expect(metadata.transform?).to be true }
    end

    describe 'with :type' do
      let(:metadata) { described_class.attributes[:type] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :type }

      it { expect(metadata.type).to be Symbol }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.default).to be nil }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::SymbolTransform
      end

      it { expect(metadata.transform?).to be true }
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

      it { expect(metadata.transform?).to be false }
    end
  end

  describe '::denormalize' do
    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'name'         => 'Kuunavang',
          'capture_date' => '2006-04-28T12:30:00+0000',
          'capture_odds' => '0.5e-1',
          'design_time'  => 1_161_820_800,
          'level'        => 30,
          'release_date' => '2005-04-26',
          'type'         => 'dragon',
          'stats'        => {
            'attack'   => 40,
            'defense'  => 30,
            'cuteness' => 50
          }
        }
      end
      let(:expected) do
        {
          name:         'Kuunavang',
          capture_date: DateTime.new(2006, 4, 28, 12, 30),
          capture_odds: BigDecimal('0.05'),
          design_time:  Time.utc(2006, 10, 26),
          level:        30,
          release_date: Date.new(2005, 4, 26),
          type:         :dragon,
          stats:        described_class::Stats.new(40, 30, 50)
        }
      end

      it 'should return an instance of the entity class' do
        expect(described_class.denormalize(attributes)).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize(attributes).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize(attributes).primary_key)
          .to be_a String
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the attributes include a primary key' do
        let(:monster_uuid) { 'b87dcd42-f027-4f9b-a0e4-20ed207737dc' }
        let(:attributes)   { super().merge('uuid' => monster_uuid) }
        let(:expected)     { super().merge(uuid: monster_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
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
          uuid:         monster.uuid,
          capture_date: nil,
          capture_odds: initial_attributes[:capture_odds],
          design_time:  nil,
          name:         'Rotscale',
          level:        30,
          release_date: initial_attributes[:release_date],
          stats:        nil,
          type:         nil
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
          uuid:         monster.uuid,
          capture_date: nil,
          capture_odds: initial_attributes[:capture_odds],
          design_time:  nil,
          name:         'Rotscale',
          level:        30,
          release_date: initial_attributes[:release_date],
          stats:        nil,
          type:         nil
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
          uuid:         monster.uuid,
          capture_date: nil,
          capture_odds: nil,
          design_time:  nil,
          name:         nil,
          level:        nil,
          release_date: nil,
          stats:        nil,
          type:         nil
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
          uuid:         monster.uuid,
          capture_date: nil,
          capture_odds: nil,
          design_time:  nil,
          name:         'Rotscale',
          level:        30,
          release_date: nil,
          stats:        nil,
          type:         nil
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
          uuid:         monster.uuid,
          capture_date: nil,
          capture_odds: nil,
          design_time:  nil,
          name:         'Rotscale',
          level:        30,
          release_date: nil,
          stats:        nil,
          type:         nil
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
        "capture_date: #{monster.capture_date.inspect}, " \
        "capture_odds: #{monster.capture_odds.inspect}, " \
        "design_time: #{monster.design_time.inspect}, " \
        "level: #{monster.level.inspect}, " \
        "release_date: #{monster.release_date.inspect}, " \
        "stats: #{monster.stats.inspect}, " \
        "type: #{monster.type.inspect}>"
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

  describe '#normalize' do
    let(:expected_capture_date) do
      transform = Bronze::Transforms::Attributes::DateTimeTransform.instance

      transform.normalize(monster.capture_date)
    end
    let(:expected_capture_odds) do
      transform = Bronze::Transforms::Attributes::BigDecimalTransform.instance

      transform.normalize(monster.capture_odds)
    end
    let(:expected_design_time) do
      transform = Bronze::Transforms::Attributes::TimeTransform.instance

      transform.normalize(monster.design_time)
    end
    let(:expected_release_date) do
      transform = Bronze::Transforms::Attributes::DateTransform.instance

      transform.normalize(monster.release_date)
    end
    let(:expected_stats) do
      {
        attack:   monster.stats.attack,
        defense:  monster.stats.defense,
        cuteness: monster.stats.cuteness
      }
    end
    let(:expected_type) do
      monster.type.to_s
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:initial_attributes) do
      super().merge(
        capture_date: DateTime.new(2006, 4, 28, 12, 30),
        design_time:  Time.new(2006, 10, 26),
        stats:        described_class::Stats.new(20, 15, 5),
        type:         :animal
      )
    end
    let(:expected) do
      hsh =
        default_attributes
        .merge(initial_attributes)
        .merge(uuid: monster.uuid)
        .merge(
          capture_date: expected_capture_date,
          capture_odds: expected_capture_odds,
          design_time:  expected_design_time,
          release_date: expected_release_date,
          stats:        expected_stats,
          type:         expected_type
        )

      tools.hash.convert_keys_to_strings(hsh)
    end

    it { expect(monster.normalize).to be == expected }
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
