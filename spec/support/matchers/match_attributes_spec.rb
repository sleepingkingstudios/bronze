# frozen_string_literal: true

require 'support/matchers/match_attributes'

# rubocop:disable RSpec/FilePath
RSpec.describe RSpec::SleepingKingStudios::Matchers::Macros do
  let(:matcher_class) do
    RSpec::SleepingKingStudios::Matchers::Core::DeepMatcher
  end
  let(:example_group) { self }

  describe '#match_attributes' do
    let(:matcher)  { example_group.match_attributes(expected) }
    let(:expected) { { id: 0 } }

    it 'should define the macro' do
      expect(example_group).to respond_to(:match_attributes).with(1).argument
    end

    it { expect(matcher).to be_a RSpec::Matchers::AliasedMatcher }

    it { expect(matcher.base_matcher).to be_a matcher_class }

    it { expect(matcher.description).to be == "match #{expected.inspect}" }
  end
end
# rubocop:enable RSpec/FilePath
