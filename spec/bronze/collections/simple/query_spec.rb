# frozen_string_literal: true

require 'bronze/collections/simple/query'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::Simple::Query do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new(raw_data) }

  let(:raw_data) { [] }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  include_examples 'should implement the Query interface'

  include_examples 'should implement the Query methods'
end
