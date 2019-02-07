# frozen_string_literal: true

require 'bronze/not_implemented_error'

RSpec.describe Bronze::NotImplementedError do
  subject(:exception) { described_class.new(receiver, method_name) }

  let(:receiver)    { 'scripture' }
  let(:method_name) { :to_enochian }

  it { expect(described_class).to be < StandardError }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end

  describe '#message' do
    let(:expected) { "#{receiver.class}##{method_name} is not implemented" }

    it { expect(exception.message).to be == expected }

    context 'when the receiver is a Module' do
      let(:receiver) { String }
      let(:expected) { "#{receiver}.#{method_name} is not implemented" }

      it { expect(exception.message).to be == expected }
    end
  end
end
