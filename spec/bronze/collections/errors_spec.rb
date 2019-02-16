# frozen_string_literal: true

require 'bronze/collections/errors'

RSpec.describe Bronze::Collections::Errors do
  describe '::DATA_EMPTY' do
    include_examples 'should define immutable constant',
      :DATA_EMPTY,
      'bronze.collections.errors.data_empty'
  end

  describe '::DATA_INVALID' do
    include_examples 'should define immutable constant',
      :DATA_INVALID,
      'bronze.collections.errors.data_invalid'
  end

  describe '::DATA_MISSING' do
    include_examples 'should define immutable constant',
      :DATA_MISSING,
      'bronze.collections.errors.data_missing'
  end

  describe '::SELECTOR_INVALID' do
    include_examples 'should define immutable constant',
      :SELECTOR_INVALID,
      'bronze.collections.errors.selector_invalid'
  end

  describe '::SELECTOR_MISSING' do
    include_examples 'should define immutable constant',
      :SELECTOR_MISSING,
      'bronze.collections.errors.selector_missing'
  end

  describe '#data_empty' do
    include_examples 'should define class reader',
      :data_empty,
      'bronze.collections.errors.data_empty'
  end

  describe '#data_invalid' do
    include_examples 'should define class reader',
      :data_invalid,
      'bronze.collections.errors.data_invalid'
  end

  describe '#data_missing' do
    include_examples 'should define class reader',
      :data_missing,
      'bronze.collections.errors.data_missing'
  end

  describe '#selector_invalid' do
    include_examples 'should define class reader',
      :selector_invalid,
      'bronze.collections.errors.selector_invalid'
  end

  describe '#selector_missing' do
    include_examples 'should define class reader',
      :selector_missing,
      'bronze.collections.errors.selector_missing'
  end
end
