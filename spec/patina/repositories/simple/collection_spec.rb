# spec/patina/repositories/simple/collection_spec.rb

require 'bronze/repositories/collection_examples'
require 'patina/repositories/simple/collection'
require 'patina/repositories/simple/query'

RSpec.describe Patina::Repositories::Simple::Collection do
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup
  include Spec::Repositories::CollectionExamples

  shared_context 'when the collection contains many items' do
    include_examples 'when many items are defined for the collection'

    before(:example) do
      data.each do |attributes|
        instance.insert attributes
      end # each
    end # before example
  end # shared_context

  let(:instance)    { described_class.new }
  let(:query_class) { Patina::Repositories::Simple::Query }

  def find_item id
    instance.all.to_a.find { |hsh| hsh[:id] == id }
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  describe '#all' do
    include_examples 'should implement #all'
  end # describe

  describe '#count' do
    include_examples 'should implement #count'
  end # describe

  describe '#delete' do
    def perform_action
      instance.delete id
    end # method perform_action

    include_examples 'should implement #delete'

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

    include_examples 'should implement #insert'

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

  describe '#update' do
    let(:id)         { '1' }
    let(:attributes) { {} }

    def perform_action
      instance.update id, attributes
    end # method perform_action

    include_examples 'should implement #update'

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
