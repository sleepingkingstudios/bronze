# lib/patina.rb

# Extensions and applications of the Bronze application toolkit.
module Patina
  # The file path to the root of the Bronze directory.
  def self.gem_path
    @gem_path ||= __dir__.sub %r{/lib\z}, ''
  end # method

  # The file path to the root of the Bronze code files directory.
  def self.lib_path
    File.join gem_path, 'lib'
  end # method
end # module
