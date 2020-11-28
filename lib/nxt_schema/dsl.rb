module NxtSchema
  module Dsl
    DEFAULT_OPTIONS = { type_system: NxtSchema::Types }.freeze

    def collection(name = :root, type: NxtSchema::Template::Collection::DEFAULT_TYPE, **options, &block)
      NxtSchema::Template::Collection.new(
        name: name,
        type: type,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end

    alias nodes collection

    def schema(name = :roots, type: NxtSchema::Template::Schema::DEFAULT_TYPE, **options, &block)
      NxtSchema::Template::Schema.new(
        name: name,
        type: type,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end

    def any_of(name = :roots, **options, &block)
      NxtSchema::Template::AnyOf.new(
        name: name,
        parent_node: nil,
        **DEFAULT_OPTIONS.merge(options),
        &block
      )
    end

    # schema root with NxtSchema::Types::Params type system

    def params(name = :params, type: NxtSchema::Template::Schema::DEFAULT_TYPE, **options, &block)
      NxtSchema::Template::Schema.new(
        name: name,
        type: type,
        parent_node: nil,
        **options.merge(type_system: NxtSchema::Types::Params),
        &block
      )
    end
  end
end
