module NxtSchema
  module Dsl
    def array(name = :root, **options, &block)
      NxtSchema::Node::Array.new(name: name, parent_node: nil, **options, &block)
    end

    def hash(name = :roots, **options, &block)
      NxtSchema::Node::Hash.new(name: name, parent_node: nil, **options, &block)
    end
  end
end
