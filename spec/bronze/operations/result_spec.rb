require 'bronze/operations/result'

RSpec.describe Bronze::Operations::Result do
  subject(:instance) { described_class.new(value, errors: errors) }

  let(:value)  { 'result value' }
  let(:errors) { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0..1).arguments
        .and_keywords(:errors)
    end
  end

  describe '#errors' do
    include_examples 'should have reader', :errors

    it { expect(instance.errors).to be_a Bronze::Errors }

    it { expect(instance.errors).to be_empty }
  end

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false
  end

  describe '#success?' do
    include_examples 'should have predicate', :success?, true
  end

  describe '#value' do
    include_examples 'should have reader', :value, -> { value }
  end
end
