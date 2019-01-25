# frozen_string_literal: true

require 'support/matchers/not_yield_control'

# rubocop:disable RSpec/FilePath
RSpec.describe RSpec::Matchers do
  let(:matcher_class) do
    RSpec::Matchers::BuiltIn::YieldControl
  end
  let(:example_group) { self }

  describe '#not_yield_control' do
    let(:matcher) { example_group.not_yield_control }

    it 'should define the macro' do
      expect(example_group).to respond_to(:not_yield_control).with(0).arguments
    end

    it { expect(matcher).to be_a RSpec::Matchers::AliasedMatcher }

    it { expect(matcher.base_matcher).to be_a matcher_class }

    it { expect(matcher.description).to be == 'not yield control' }
  end
end
# rubocop:enable RSpec/FilePath
