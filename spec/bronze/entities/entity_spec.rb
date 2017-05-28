# spec/bronze/entities/entity_spec.rb

require 'bronze/entities/entity'

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/attributes/attributes_examples'
require 'bronze/entities/attributes/dirty_tracking_examples'
require 'bronze/entities/normalization_examples'
require 'bronze/entities/persistence_examples'
require 'bronze/entities/primary_key_examples'
require 'bronze/entities/uniqueness_examples'

RSpec.describe Bronze::Entities::Entity do
  include Spec::Entities::Associations::AssociationsExamples
  include Spec::Entities::Attributes::AttributesExamples
  include Spec::Entities::Attributes::DirtyTrackingExamples
  include Spec::Entities::NormalizationExamples
  include Spec::Entities::PersistenceExamples
  include Spec::Entities::PrimaryKeyExamples
  include Spec::Entities::UniquenessExamples

  mock_class Spec, :Book, :base_class => Bronze::Entities::Entity

  shared_context 'when an entity class is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  let(:described_class)      { Spec::Book }
  let(:entity_class)         { described_class }
  let(:defined_attributes)   { { :id => String } }
  let(:defined_associations) { {} }
  let(:attributes)           { {} }
  let(:instance)             { described_class.new(attributes) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Associations methods'

  include_examples 'should implement the Attributes methods'

  include_examples 'should implement the Attributes::DirtyTracking methods'

  include_examples 'should implement the Normalization methods'

  include_examples 'should implement the Persistence methods'

  include_examples 'should implement the PrimaryKey methods'

  include_examples 'should implement the Uniqueness methods'
end # describe
