# spec/support/example_entity.rb

require 'bronze/entities/entity'

module Spec
  class ExampleEntity < Bronze::Entities::Entity
    attribute :name, String

    def inspect
      %(#<#{self.class.name} #{log_attributes}>)
    end # method inspect

    private

    def log_attributes
      logged_attributes.
        select { |attr_name| respond_to?(attr_name) && !send(attr_name).nil? }.
        map    { |attr_name| "#{attr_name}=>#{send(attr_name)}" }.
        join ' '
    end # method log_attributes

    def logged_attributes
      %w[name]
    end # method logged_attributes
  end # module
end # module
