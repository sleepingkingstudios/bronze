# frozen_string_literal: true

require 'bronze/entity'

require 'support/examples/entities/attributes_examples'

RSpec.describe Bronze::Entity do
  include Support::Examples::Entities::AttributesExamples

  subject(:entity) { entity_class.new(initial_attributes) }

  let(:described_class)    { Spec::ExampleEntity }
  let(:entity_class)       { described_class }
  let(:initial_attributes) { {} }

  # rubocop:disable RSpec/DescribedClass
  example_class 'Spec::ExampleEntity', Bronze::Entity
  # rubocop:enable RSpec/DescribedClass

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  include_examples 'should implement the Attributes methods'
end
