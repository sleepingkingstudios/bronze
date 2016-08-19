# spec/bronze/repositories/collection_examples.rb

module Spec::Repositories
  module CollectionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    def self.included other
      super

      other.extend ClassMethods
    end # class method included

    module ClassMethods
      def validate_params desc, message: nil, **params
        tools      = ::SleepingKingStudios::Tools::ArrayTools
        params_ary = params.map { |key, value| ":#{key} => #{value.inspect}" }
        params_str = "with #{tools.humanize_list(params_ary)}"

        describe params_str do
          params.each do |key, value|
            let(key) { value }
          end # each

          include_examples 'should fail with message', message || desc
        end # describe
      end # class method validate
    end # module

    shared_examples 'should implement the Collection interface' do
      describe '#all' do
        it { expect(instance).to respond_to(:all).with(0).arguments }
      end # describe

      describe '#count' do
        it { expect(instance).to respond_to(:count).with(0).arguments }
      end # describe

      describe '#delete' do
        it { expect(instance).to respond_to(:delete).with(1).argument }
      end # describe

      describe '#insert' do
        it { expect(instance).to respond_to(:insert).with(1).argument }
      end # describe

      describe '#update' do
        it { expect(instance).to respond_to(:update).with(2).arguments }
      end # describe
    end # shared_examples

    shared_examples 'should fail with message' do |message = nil|
      let(:error_message) do
        msg = defined?(super()) ? super() : message

        msg.is_a?(Proc) ? instance_exec(&msg) : msg
      end # let

      desc = 'should fail with message'
      desc << ' ' << message.inspect if message

      it desc do
        result = nil
        errors = nil

        expect { result, errors = perform_action }.
          not_to change(instance.all, :to_a)

        expect(result).to be false
        expect(errors).to contain_exactly error_message
      end # it
    end # shared_examples

    shared_examples 'should delete the item' do
      it 'should delete the item' do
        result = nil
        errors = nil

        expect { result, errors = instance.delete id }.
          to change(instance, :count).by(-1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.all.to_a.find { |hsh| hsh[:id] == id }
        expect(item).to be nil
      end # it
    end # shared_examples

    shared_examples 'should insert the item' do
      it 'should insert an item' do
        result = nil
        errors = nil

        expect { result, errors = instance.insert attributes }.
          to change(instance, :count).by(1)

        expect(result).to be true
        expect(errors).to be == []

        item = instance.all.to_a.last

        expect(item).to be == attributes
      end # it
    end # shared_examples

    shared_examples 'should update the item' do
      it 'should update the item' do
        result = nil
        errors = nil

        expect { result, errors = instance.update id, attributes }.
          not_to change(instance, :count)

        expect(result).to be true
        expect(errors).to be == []

        item = find_item(id)

        attributes.each do |key, value|
          expect(item[key]).to be == value
        end # each
      end # it
    end # shared_examples
  end # module
end # module
