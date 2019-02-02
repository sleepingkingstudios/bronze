# frozen_string_literal: true

require 'support/entities/monster'
require 'support/examples/entity_examples'

RSpec.describe Spec::Monster do
  include Spec::Support::Examples::EntityExamples

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
      type:         nil,
      uuid:         nil
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
  let(:expected_attributes) do
    default_attributes
      .merge(initial_attributes)
      .merge(uuid: be_a_uuid)
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  include_examples 'should define UUID primary key', :uuid

  include_examples 'should define attribute', :capture_date, DateTime

  include_examples 'should define attribute', :capture_odds, BigDecimal

  include_examples 'should define attribute', :design_time, Time

  include_examples 'should define attribute', :level, Integer

  include_examples 'should define attribute', :name, String

  include_examples 'should define attribute', :release_date, Date

  include_examples 'should define attribute',
    :stats,
    described_class::Stats,
    transform: described_class::StatsTransform

  include_examples 'should define attribute', :type, Symbol

  describe '::attributes' do
    describe 'with :army' do
      it { expect(described_class.attributes[:army]).to be nil }
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
end
