module NxtSchema
  def schema(name = :root, **options, &block)
    Node::Schema.new(name: name, parent_node: nil, **options, &block)
  end

  def params(name = :root, **options, &block)
    Node::Schema.new(
      name: name,
      parent_node: nil,
      **options.merge(
        type_system: NxtSchema::Types::Params,
      ).reverse_merge(transform_keys: :to_sym),
      &block
    )
  end

  def json(name = :root, **options, &block)
    Node::Schema.new(
      name: name,
      parent_node: nil,
      **options.merge(
        type_system: NxtSchema::Types::JSON,
      ).reverse_merge(transform_keys: :to_sym),
      &block
    )
  end

  def collection(name = :roots, **options, &block)
    Node::Collection.new(name: name, parent_node: nil, **options, &block)
  end

  alias_method :new, :schema
  alias_method :node, :schema
  alias_method :root, :schema
  alias_method :nodes, :collection
  alias_method :roots, :collection

  module_function :new, :root, :roots, :node, :nodes, :collection, :schema, :params
end
