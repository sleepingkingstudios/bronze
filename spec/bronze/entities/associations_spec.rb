# spec/bronze/entities/associations_spec.rb

require 'bronze/entities/associations'
require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/attributes'
require 'bronze/entities/entity'
require 'bronze/entities/primary_key'

RSpec.describe Bronze::Entities::Associations do
  include Spec::Entities::Associations::AssociationsExamples

  options = { :base_class => Bronze::Entities::BaseEntity }
  example_class 'Spec::Book', options do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::PrimaryKey
    klass.send :include, Bronze::Entities::Associations
  end # example_class

  let(:described_class)      { Spec::Book }
  let(:entity_class)         { described_class }
  let(:defined_associations) { {} }
  let(:initial_attributes)   { {} }
  let(:instance)             { described_class.new initial_attributes }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Associations methods'
end # describe
