module NxtSchema
  module Dsl
    def array(name = :root, **options, &block)
      default_options = { type_system: NxtSchema::Types }
      NxtSchema::Node::Array.new(name: name, parent_node: nil, **default_options.merge(options), &block)
    end

    def hash(name = :roots, **options, &block)
      default_options = { type_system: NxtSchema::Types }
      NxtSchema::Node::Hash.new(name: name, parent_node: nil, **default_options.merge(options), &block)
    end
  end
end
