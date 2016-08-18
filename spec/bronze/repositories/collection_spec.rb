# spec/bronze/repositories/collection_spec.rb

require 'bronze/repositories/collection'
require 'bronze/repositories/collection_examples'

RSpec.describe Bronze::Repositories::Collection do
  include Spec::Repositories::CollectionExamples

  let(:described_class) { Class.new.send :include, super() }
  let(:instance)        { described_class.new }

  include_examples 'should implement the Collection interface'
end # describe
