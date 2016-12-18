# spec/patina_spec.rb

require 'patina'

RSpec.describe Patina do
  describe '::gem_path' do
    let(:root_path) { __dir__.sub %r{/spec\z}, '' }

    it { expect(described_class).to respond_to(:gem_path).with(0).arguments }

    it 'should return the root path' do
      expect(described_class.gem_path).to be == root_path
    end # it
  end # describe

  describe '::lib_path' do
    let(:root_path) { __dir__.sub %r{/spec\z}, '' }

    it { expect(described_class).to respond_to(:lib_path).with(0).arguments }

    it 'should return the root path' do
      expect(described_class.lib_path).to be == File.join(root_path, 'lib')
    end # it
  end # describe
end # describe
