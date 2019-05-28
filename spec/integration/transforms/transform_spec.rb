# frozen_string_literal: true

require 'support/transforms/stringify_transform'
require 'support/transforms/symbolize_transform'
require 'support/transforms/underscore_transform'
require 'support/transforms/upcase_transform'

RSpec.describe Bronze::Transform do
  let(:stringify)  { Spec::StringifyTransform.new }
  let(:symbolize)  { Spec::SymbolizeTransform.new }
  let(:underscore) { Spec::UnderscoreTransform.new }
  let(:upcase)     { Spec::UpcaseTransform.new }

  describe 'left composition' do
    describe 'with two composed transforms' do
      let(:composed_transform) do
        underscore >> upcase
      end

      describe 'when #denormalize is called' do
        let(:input)  { 'GREETINGS_PROGRAMS' }
        let(:output) { 'GreetingsPrograms' }

        it 'should chain the transforms' do
          expect(composed_transform.denormalize(input)).to be == output
        end
      end

      describe 'when #normalize is called' do
        let(:input)  { 'GreetingsPrograms' }
        let(:output) { 'GREETINGS_PROGRAMS' }

        it 'should chain the transforms' do
          expect(composed_transform.normalize(input)).to be == output
        end
      end
    end

    describe 'with three composed transforms' do
      let(:composed_transform) do
        underscore >> upcase >> symbolize
      end

      describe 'when #denormalize is called' do
        let(:input)  { :GREETINGS_PROGRAMS }
        let(:output) { 'GreetingsPrograms' }

        it 'should chain the transforms' do
          expect(composed_transform.denormalize(input)).to be == output
        end
      end

      describe 'when #normalize is called' do
        let(:input)  { 'GreetingsPrograms' }
        let(:output) { :GREETINGS_PROGRAMS }

        it 'should chain the transforms' do
          expect(composed_transform.normalize(input)).to be == output
        end
      end
    end
  end

  describe 'right composition' do
    describe 'with two composed transforms' do
      let(:composed_transform) do
        upcase << underscore
      end

      describe 'when #denormalize is called' do
        let(:input)  { 'GREETINGS_PROGRAMS' }
        let(:output) { 'GreetingsPrograms' }

        it 'should chain the transforms' do
          expect(composed_transform.denormalize(input)).to be == output
        end
      end

      describe 'when #normalize is called' do
        let(:input)  { 'GreetingsPrograms' }
        let(:output) { 'GREETINGS_PROGRAMS' }

        it 'should chain the transforms' do
          expect(composed_transform.normalize(input)).to be == output
        end
      end
    end

    describe 'with three composed transforms' do
      let(:composed_transform) do
        symbolize << upcase << underscore
      end

      describe 'when #denormalize is called' do
        let(:input)  { :GREETINGS_PROGRAMS }
        let(:output) { 'GreetingsPrograms' }

        it 'should chain the transforms' do
          expect(composed_transform.denormalize(input)).to be == output
        end
      end

      describe 'when #normalize is called' do
        let(:input)  { 'GreetingsPrograms' }
        let(:output) { :GREETINGS_PROGRAMS }

        it 'should chain the transforms' do
          expect(composed_transform.normalize(input)).to be == output
        end
      end
    end
  end
end
