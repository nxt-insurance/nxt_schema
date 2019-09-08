module NxtSchema
  def new(&block)
    Node::Root.new(nil, nil, {}, &block)
  end

  # TODO: Test these
  def root(&block)
    Node::Hash.new(nil, nil, {}, &block)
  end

  def roots(&block)
    Node::Array.new(nil, nil, {}, &block)
  end

  module_function :new, :root, :roots
end
