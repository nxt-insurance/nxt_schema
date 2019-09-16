module NxtSchema
  def hash(name = :root, &block)
    Node::Hash.new(name: name, parent_node: nil, &block)
  end

  def array(name = :roots, &block)
    Node::Array.new(name: name, parent_node: nil, &block)
  end

  alias_method :new, :hash
  alias_method :node, :hash
  alias_method :schema, :hash
  alias_method :root, :hash
  alias_method :nodes, :array
  alias_method :roots, :array

  module_function :new, :root, :roots, :node, :nodes, :hash, :array, :schema
end
