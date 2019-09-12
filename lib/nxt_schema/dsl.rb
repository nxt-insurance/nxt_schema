module NxtSchema
  def new(&block)
    Node::Root.new(name: nil, parent_node: nil, &block)
  end

  def root(&block)
    Node::Hash.new(name: :root, parent_node: nil, &block)
  end

  def roots(&block)
    Node::Array.new(name: :roots, parent_node: nil, &block)
  end

  module_function :new, :root, :roots
end
