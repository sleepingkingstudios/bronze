# spec/patina/operations/entities/entity_operation_examples.rb

require 'sleeping_king_studios/tools/toolbelt'

module Spec::Operations
  module EntityOperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the collection contains many resources' do
      let(:resources_attributes) do
        ary = []

        title = 'Astrology Today'
        1.upto(3) { |i| ary << { :title => title, :volume => i } }

        title = 'Journal of Applied Phrenology'
        4.upto(6) { |i| ary << { :title => title, :volume => i } }

        ary
      end # let
      let(:resources) do
        resources_attributes.map { |hsh| resource_class.new hsh }
      end # let

      before(:example) do
        resources.each do |resource|
          instance.send(:collection).insert resource
        end # each
      end # before
    end # shared_context
  end # module
end # module
