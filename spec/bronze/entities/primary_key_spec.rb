# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/primary_key'

require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/primary_key_examples'

RSpec.describe Bronze::Entities::PrimaryKey do
  include Support::Examples::Entities::AttributesExamples
  include Support::Examples::Entities::PrimaryKeyExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)    { Spec::EntityWithPrimaryKey }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::EntityWithPrimaryKey' do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::PrimaryKey
  end
  # rubocop:enable RSpec/DescribedClass

  include_examples 'should implement the PrimaryKey methods'

  include_examples 'should implement the generic PrimaryKey methods'
end
