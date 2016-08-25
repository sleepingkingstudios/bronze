# spec/bronze/collections/collection_spec.rb

require 'bronze/collections/collection'
require 'bronze/collections/collection_examples'

RSpec.describe Bronze::Collections::Collection do
  include Spec::Collections::CollectionExamples

  let(:described_class) { Class.new.send :include, super() }
  let(:instance)        { described_class.new }

  include_examples 'should implement the Collection interface'
end # describe
