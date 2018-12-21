# frozen_string_literal: true

require 'bigdecimal'
require 'date'

require 'bronze/entity'
require 'bronze/entities/primary_keys/uuid'
require 'bronze/transform'

module Spec
  class Monster < Bronze::Entity
    include Bronze::Entities::PrimaryKeys::Uuid

    Stats = Struct.new(:attack, :defense, :cuteness)

    class StatsTransform < Bronze::Transform
      def denormalize(hsh)
        return nil if hsh.nil?

        Spec::Monster::Stats.new(
          hsh['attack'],
          hsh['defense'],
          hsh['cuteness']
        )
      end

      def normalize(stats)
        return nil if stats.nil?

        {
          'attack'   => stats.attack,
          'defense'  => stats.defense,
          'cuteness' => stats.cuteness
        }
      end
    end

    define_primary_key :uuid

    attribute :name,         String
    attribute :capture_date, DateTime
    attribute :capture_odds, BigDecimal
    attribute :design_time,  Time
    attribute :level,        Integer
    attribute :release_date, Date
    attribute :stats,        Stats, transform: StatsTransform
    attribute :type,         Symbol
  end
end
