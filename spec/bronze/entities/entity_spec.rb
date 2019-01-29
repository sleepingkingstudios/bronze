# spec/bronze/entities/entity_spec.rb

require 'securerandom'

require 'bronze/entities/entity'

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/attributes/dirty_tracking_examples'
require 'bronze/entities/normalization/associations_examples'
require 'bronze/entities/persistence_examples'
require 'bronze/entities/uniqueness_examples'

require 'support/examples/entities/attributes_examples'
require 'support/examples/entities/normalization_examples'
require 'support/examples/entities/primary_key_examples'

RSpec.describe Bronze::Entities::Entity do
  include Spec::Entities::Associations::AssociationsExamples
  include Spec::Entities::Attributes::DirtyTrackingExamples
  include Spec::Entities::Normalization::AssociationsExamples
  include Spec::Entities::PersistenceExamples
  include Spec::Entities::UniquenessExamples
  include Spec::Support::Examples::Entities::AttributesExamples
  include Spec::Support::Examples::Entities::NormalizationExamples
  include Spec::Support::Examples::Entities::PrimaryKeyExamples

  shared_context 'when an entity class is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)      { Spec::Book }
  let(:entity_class)         { described_class }
  let(:defined_attributes)   { [:id] }
  let(:defined_associations) { {} }
  let(:attributes)           { initial_attributes }
  let(:initial_attributes)   { {} }
  let(:default_attributes)   { {} }
  let(:instance)             { entity }
  let(:expected_attributes) do
    default_attributes.merge(initial_attributes)
  end

  example_class 'Spec::Book', :base_class => Bronze::Entities::Entity

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Attributes methods'

  include_examples 'should implement the Attributes::DirtyTracking methods'

  include_examples 'should implement the Normalization methods'

  include_examples 'should implement the Persistence methods'

  include_examples 'should implement the PrimaryKey methods'

  wrap_context 'when the entity class has a primary key' do
    let(:primary_key_type)    { String }
    let(:primary_key_value)   { '02ca3132-c872-41f6-98bb-1f2d4e07e952' }
    let(:primary_key_default) { -> { SecureRandom.uuid } }

    include_examples 'should implement the Associations methods'

    include_examples 'should implement the Normalization::Associations methods'

    include_examples 'should implement the Uniqueness methods'
  end
end # describe
