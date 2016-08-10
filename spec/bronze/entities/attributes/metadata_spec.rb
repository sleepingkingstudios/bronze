# spec/bronze/entities/attributes/metadata_spec.rb

require 'bronze/entities/attributes/metadata'

RSpec.describe Bronze::Entities::Attributes::Metadata do
  let(:attribute_name) { :title }
  let(:attribute_type) { String }
  let(:instance)       { described_class.new(attribute_name, attribute_type) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  describe '#attribute_name' do
    include_examples 'should have reader', :attribute_name, lambda {
      be == attribute_name
    } # end lambda
  end # describe

  describe '#attribute_type' do
    include_examples 'should have reader', :attribute_type, lambda {
      be == attribute_type
    } # end lambda
  end # describe

  describe '#default_value' do
    include_examples 'should have reader', :default_value, nil
  end # describe

  describe '#reader_name' do
    include_examples 'should have reader', :reader_name, lambda {
      be == attribute_name
    } # end lambda
  end # describe

  describe '#writer_name' do
    include_examples 'should have reader', :writer_name, lambda {
      be == :"#{attribute_name}="
    } # end lambda
  end # describe
end # describe
