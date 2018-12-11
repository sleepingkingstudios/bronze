# frozen_string_literal: true

require 'bronze/entities/attributes'

require 'support/examples/entities/attributes_examples'

RSpec.describe Bronze::Entities::Attributes do
  include Support::Examples::Entities::AttributesExamples

  subject(:entity) { described_class.new(initial_attributes) }

  let(:described_class)    { Spec::EntityWithAttributes }
  let(:initial_attributes) { {} }

  example_class 'Spec::EntityWithAttributes' do |klass|
    # rubocop:disable RSpec/DescribedClass
    klass.send :include, Bronze::Entities::Attributes
    # rubocop:enable RSpec/DescribedClass
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  include_examples 'should implement the Attributes methods'
end
