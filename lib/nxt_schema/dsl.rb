module NxtSchema
  module Dsl
    def collection(name = :root, **options, &block)
      default_options = { type_system: NxtSchema::Types }
      NxtSchema::Node::Collection.new(name: name, parent_node: nil, **default_options.merge(options), &block)
    end

    def schema(name = :roots, **options, &block)
      default_options = { type_system: NxtSchema::Types }
      NxtSchema::Node::Schema.new(name: name, parent_node: nil, **default_options.merge(options), &block)
    end
  end
end
