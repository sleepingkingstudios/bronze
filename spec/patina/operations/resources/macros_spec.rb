# spec/patina/operations/resources/macros_spec.rb

require 'bronze/entities/entity'
require 'bronze/operations/operation'

require 'patina/operations/resources/macros'

RSpec.describe Patina::Operations::Resources::Macros do
  shared_context 'when a resource mapping is defined' do
    before(:example) do
      allow(described_class).
        to receive(:resource_class_for).
        with(:periodical).
        and_return(resource_class)
    end # before
  end # shared_context

  shared_examples 'should include the mixin and set the resource class' do
    let(:resource) { Spec::Periodical }

    it 'should include the mixin' do
      call_macro resource

      expect(described_class).to be < mixin
    end # it

    it 'should set the resource class' do
      call_macro resource

      expect(described_class.resource_class).to be resource_class
    end # it

    describe 'with a resource name' do
      let(:resource) { :periodical }

      it 'should raise an error' do
        expect { call_macro resource }.
          to raise_error ArgumentError, "unknown resource #{resource.inspect}"
      end # it

      wrap_context 'when a resource mapping is defined' do
        it 'should include the mixin' do
          call_macro resource

          expect(described_class).to be < mixin
        end # it

        it 'should set the resource class' do
          call_macro resource

          expect(described_class.resource_class).to be resource_class
        end # it
      end # wrap_context
    end # describe
  end # shared_examples

  let(:described_class) do
    klass = Class.new(Bronze::Operations::Operation)

    klass.send :include, super()

    klass
  end # let
  let(:resource_class) { Spec::Periodical }

  mock_class Spec, :Periodical, :base_class => Bronze::Entities::Entity

  describe '::build_one' do
    let(:mixin) { Patina::Operations::Resources::BuildOneResourceOperation }

    def call_macro resource
      described_class.build_one resource
    end # method call_macro

    it { expect(described_class).to respond_to(:build_one).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::create_one' do
    let(:mixin) { Patina::Operations::Resources::CreateOneResourceOperation }

    def call_macro resource
      described_class.create_one resource
    end # method call_macro

    it { expect(described_class).to respond_to(:create_one).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::destroy_one' do
    let(:mixin) { Patina::Operations::Resources::DestroyOneResourceOperation }

    def call_macro resource
      described_class.destroy_one resource
    end # method call_macro

    it { expect(described_class).to respond_to(:destroy_one).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::find_matching' do
    let(:mixin) do
      Patina::Operations::Resources::FindMatchingResourcesOperation
    end # let

    def call_macro resource
      described_class.find_matching resource
    end # method call_macro

    it 'should define the macro' do
      expect(described_class).to respond_to(:find_matching).with(1).argument
    end # it

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::find_many' do
    let(:mixin) { Patina::Operations::Resources::FindManyResourcesOperation }

    def call_macro resource
      described_class.find_many resource
    end # method call_macro

    it { expect(described_class).to respond_to(:find_many).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::find_one' do
    let(:mixin) { Patina::Operations::Resources::FindOneResourceOperation }

    def call_macro resource
      described_class.find_one resource
    end # method call_macro

    it { expect(described_class).to respond_to(:find_one).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe

  describe '::update_one' do
    let(:mixin) { Patina::Operations::Resources::UpdateOneResourceOperation }

    def call_macro resource
      described_class.update_one resource
    end # method call_macro

    it { expect(described_class).to respond_to(:update_one).with(1).argument }

    include_examples 'should include the mixin and set the resource class'
  end # describe
end # describe
