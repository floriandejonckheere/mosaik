# frozen_string_literal: true

# typed: strict

module MOSAIK
  module Graph
    extend T::Sig

    ##
    # Attributes of an edge
    #
    Attributes = T.type_alias { T::Hash[Symbol, T.untyped] }
  end
end
