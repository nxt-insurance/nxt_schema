module NxtSchema
  module Dsl
    def collection(name = :root, value_type: NxtSchema::Node::Collection::DEFAULT_TYPE, **options, &block)
      default_options = { type_system: NxtSchema::Types }

      NxtSchema::Node::Collection.new(
        name: name,
        value_type: value_type,
        parent_node: nil,
        **default_options.merge(options),
        &block
      )
    end

    alias nodes collection

    def schema(name = :roots, value_type: NxtSchema::Node::Schema::DEFAULT_TYPE, **options, &block)
      default_options = { type_system: NxtSchema::Types }

      NxtSchema::Node::Schema.new(
        name: name,
        value_type: value_type,
        parent_node: nil,
        **default_options.merge(options),
        &block
      )
    end
  end
end
