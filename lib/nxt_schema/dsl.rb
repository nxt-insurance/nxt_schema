module NxtSchema
  module Dsl
    def collection(name = :root, type: NxtSchema::Node::Collection::DEFAULT_TYPE, **options, &block)
      default_options = { type_system: NxtSchema::Types }

      NxtSchema::Node::Collection.new(
        name: name,
        type: type,
        parent_node: nil,
        **default_options.merge(options),
        &block
      )
    end

    alias nodes collection

    def schema(name = :roots, type: NxtSchema::Node::Schema::DEFAULT_TYPE, **options, &block)
      default_options = { type_system: NxtSchema::Types }

      NxtSchema::Node::Schema.new(
        name: name,
        type: type,
        parent_node: nil,
        **default_options.merge(options),
        &block
      )
    end
  end
end
