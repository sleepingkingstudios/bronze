# spec/patina/collections/simple/collection_spec.rb

require 'bronze/collections/collection_examples'
require 'patina/collections/simple/collection'
require 'patina/collections/simple/query'

RSpec.describe Patina::Collections::Simple::Collection do
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Collections::CollectionExamples

  let(:data)        { [] }
  let(:instance)    { described_class.new }
  let(:query_class) { Patina::Collections::Simple::Query }

  before(:example) do
    data.each do |attributes|
      instance.insert instance.transform.denormalize(attributes)
    end # each
  end # before example

  def find_item id
    items = instance.all.to_a

    if items.empty?
      nil
    elsif items.first.is_a?(Hash)
      items.find { |hsh| hsh[:id] == id }
    else
      items.find { |obj| obj.id == id }
    end # if-elsif-else
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods'

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    validate_params "id can't be nil", :id => nil

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params "id can't be nil", :id => nil

      validate_params 'item not found with id "0"', :id => '0'
    end # wrap_context
  end # describe

  describe '#insert' do
    def perform_action
      instance.insert attributes
    end # method perform_action

    validate_params "data can't be nil", :attributes => nil

    validate_params 'data must be a Hash', :attributes => Object.new

    validate_params "id can't be nil", :attributes => {}

    validate_params "id can't be nil", :attributes => { :title => 'The Hobbit' }

    wrap_context 'when the collection contains many items' do
      validate_params "data can't be nil", :attributes => nil

      validate_params 'data must be a Hash', :attributes => Object.new

      validate_params "id can't be nil", :attributes => {}

      validate_params "id can't be nil",
        :attributes => { :title => 'The Hobbit' }

      validate_params 'id already exists',
        :attributes => { :id => '1', :title => 'The Hobbit' }
    end # wrap_context
  end # describe

  describe '#transform' do
    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new transform }

      it { expect(instance.transform).to be transform }
    end # context
  end # describe

  describe '#update' do
    let(:id)         { '1' }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    validate_params "id can't be nil", :id => nil

    validate_params 'item not found with id "0"', :id => '0'

    wrap_context 'when the collection contains many items' do
      validate_params "id can't be nil", :id => nil

      validate_params 'item not found with id "0"', :id => '0'

      validate_params "data can't be nil", :attributes => nil

      validate_params 'data must be a Hash', :attributes => Object.new

      validate_params 'data id must match id', :attributes => { :id => 1 }
    end # wrap_context
  end # describe
end # describe
