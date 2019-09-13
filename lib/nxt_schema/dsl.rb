module NxtSchema
  def root(name = :root, &block)
    Node::Hash.new(name: name, parent_node: nil, &block)
  end

  alias_method :new, :root

  def roots(name = :roots, &block)
    Node::Array.new(name: name, parent_node: nil, &block)
  end

  module_function :new, :root, :roots
end
