module NxtSchema
  def schema(name = :root, &block)
    Node::Schema.new(name: name, parent_node: nil, &block)
  end

  def collection(name = :roots, &block)
    Node::Collection.new(name: name, parent_node: nil, &block)
  end

  alias_method :new, :schema
  alias_method :node, :schema
  alias_method :root, :schema
  alias_method :nodes, :collection
  alias_method :roots, :collection

  module_function :new, :root, :roots, :node, :nodes, :collection, :schema
end
