module NxtSchema
  def root(name = :root, &block)
    Node::Hash.new(name: name, parent_node: nil, &block)
  end

  def roots(name = :roots, &block)
    Node::Array.new(name: name, parent_node: nil, &block)
  end

  alias_method :new, :root
  alias_method :node, :root
  alias_method :nodes, :roots

  module_function :new, :root, :roots, :node, :nodes
end
