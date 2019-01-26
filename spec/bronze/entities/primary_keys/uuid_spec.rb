# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/primary_keys/uuid'

require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/primary_key_examples'

RSpec.describe Bronze::Entities::PrimaryKeys::Uuid do
  include Spec::Support::Examples::Entities::AttributesExamples
  include Spec::Support::Examples::Entities::PrimaryKeyExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)    { Spec::EntityWithUuidKey }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::EntityWithUuidKey' do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::PrimaryKeys::Uuid
  end
  # rubocop:enable RSpec/DescribedClass

  include_examples 'should implement the PrimaryKey methods' do
    let(:primary_key_type)  { String }
    let(:primary_key_value) { '02ca3132-c872-41f6-98bb-1f2d4e07e952' }
    let(:primary_key_args)  { [primary_key_name] }
  end
end
