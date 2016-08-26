# spec/bronze_spec.rb

require 'bronze'

RSpec.describe Bronze do
  describe '::gem_path' do
    let(:root_path) { __dir__.sub %r{/spec\z}, '' }

    it { expect(described_class).to respond_to(:gem_path).with(0).arguments }

    it 'should return the root path' do
      expect(described_class.gem_path).to be == root_path
    end # it
  end # describe
end # describe
