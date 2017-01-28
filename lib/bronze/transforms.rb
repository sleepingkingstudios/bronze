# lib/bronze/transforms.rb

require 'bronze'

module Bronze
  # Namespace for defining transform objects, which that map a data object into
  # another representation of that data.
  module Transforms
    autoload :TransformChain, 'bronze/transforms/transform_chain'
  end # module
end # module
