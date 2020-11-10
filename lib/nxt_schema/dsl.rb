module NxtSchema
  module Dsl
    DEFAULT_OPTIONS = { type_system: NxtSchema::Types }.freeze

    def collection(name = :root, type: NxtSchema::Node::Collection::DEFAULT_TYPE, **options, &block)
      NxtSchema::Node::Collection.new(
        name: name,
        type: type,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end

    alias nodes collection

    def schema(name = :roots, type: NxtSchema::Node::Schema::DEFAULT_TYPE, **options, &block)
      NxtSchema::Node::Schema.new(
        name: name,
        type: type,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end

    def any_of(name = :roots, **options, &block)
      NxtSchema::Node::AnyOf.new(
        name: name,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end
  end
end
