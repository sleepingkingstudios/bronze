# frozen_string_literal: true

require 'bronze/collections/adapter'

RSpec.describe Bronze::Collections::Adapter do
  subject(:adapter) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#collection_name_for' do
    it { expect(adapter).to respond_to(:collection_name_for).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { adapter.collection_name_for nil }.to raise_error NameError
      end
    end

    describe 'with an Object' do
      it 'should raise an error' do
        expect { adapter.collection_name_for Object.new }
          .to raise_error NameError
      end
    end

    describe 'with a Class' do
      example_class 'Spec::ExampleClass'

      it 'should format the class name' do
        expect(adapter.collection_name_for Spec::ExampleClass)
          .to be == 'spec__example_classes'
      end
    end

    describe 'with a Module' do
      example_constant 'Spec::ExampleModule' do
        Module.new
      end

      it 'should format the module name' do
        expect(adapter.collection_name_for Spec::ExampleModule)
          .to be == 'spec__example_modules'
      end
    end
  end

  describe '#collection_names' do
    let(:error_message) do
      'Bronze::Collections::Adapter#collection_names is not implemented'
    end

    it { expect(adapter).to respond_to(:collection_names).with(0).arguments }

    it 'should raise an error' do
      expect { adapter.collection_names }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#delete_matching' do
    let(:collection_name)   { 'books' }
    let(:primary_key)       { :uuid }
    let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
    let(:error_message) do
      'Bronze::Collections::Adapter#delete_one is not implemented'
    end

    it { expect(adapter).to respond_to(:delete_one).with(3).arguments }

    it 'should raise an error' do
      expect do
        adapter.delete_one(collection_name, primary_key, primary_key_value)
      end
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#delete_one' do
    let(:collection_name) { 'books' }
    let(:selector)        { { 'title' => 'The Ramayana' } }
    let(:error_message) do
      'Bronze::Collections::Adapter#delete_matching is not implemented'
    end

    it { expect(adapter).to respond_to(:delete_matching).with(2).arguments }

    it 'should raise an error' do
      expect { adapter.delete_matching(collection_name, selector) }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#find_one' do
    let(:collection_name) { 'books' }
    let(:primary_key)     { :id }
    let(:value)           { 0 }
    let(:error_message) do
      'Bronze::Collections::Adapter#find_one is not implemented'
    end

    it { expect(adapter).to respond_to(:find_one).with(3).arguments }

    it 'should raise an error' do
      expect do
        adapter.find_one(collection_name, value, primary_key: primary_key)
      end
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#insert_one' do
    let(:collection_name) { 'books' }
    let(:object)          { { 'title' => 'The Ramayana' } }
    let(:error_message) do
      'Bronze::Collections::Adapter#insert_one is not implemented'
    end

    it { expect(adapter).to respond_to(:insert_one).with(2).arguments }

    it 'should raise an error' do
      expect { adapter.insert_one(collection_name, object) }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#query' do
    let(:error_message) do
      'Bronze::Collections::Adapter#query is not implemented'
    end

    it { expect(adapter).to respond_to(:query).with(1).argument }

    it 'should raise an error' do
      expect { adapter.query('books') }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#update_matching' do
    let(:collection_name) { 'books' }
    let(:selector)        { { 'title' => 'The Ramayana' } }
    let(:data)            { { 'author' => 'Valmiki' } }
    let(:error_message) do
      'Bronze::Collections::Adapter#update_matching is not implemented'
    end

    it { expect(adapter).to respond_to(:update_matching).with(3).arguments }

    it 'should raise an error' do
      expect { adapter.update_matching(collection_name, selector, data) }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#update_one' do
    let(:collection_name)   { 'books' }
    let(:primary_key)       { :uuid }
    let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
    let(:data)              { { 'author' => 'Valmiki' } }
    let(:error_message) do
      'Bronze::Collections::Adapter#update_one is not implemented'
    end

    it { expect(adapter).to respond_to(:update_one).with(4).arguments }

    it 'should raise an error' do
      expect do
        adapter
          .update_one(collection_name, primary_key, primary_key_value, data)
      end
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end
end
