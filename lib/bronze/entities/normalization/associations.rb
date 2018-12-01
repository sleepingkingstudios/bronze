# lib/bronze/entities/normalization/associations.rb

require 'bronze/entities/associations/collection'
require 'bronze/entities/normalization'

module Bronze::Entities::Normalization
  # Module for transforming entities with associations to and from a normal
  # form.
  module Associations
    def normalize(associations: nil, **keywords)
      hsh = super(**keywords)

      associations ||= {}

      associations.each do |name, options|
        next unless options

        options = {} unless options.is_a?(Hash)
        options = keywords.merge(options)

        hsh[name] = normalize_association(name, options)
      end

      hsh
    end

    private

    def normalize_association(name, options)
      value = send(name)

      return value if value.nil?

      if value.is_a?(Bronze::Entities::Associations::Collection)
        return value.map { |entity| entity.normalize(options) }
      end

      value.normalize(options)
    end
  end
end
