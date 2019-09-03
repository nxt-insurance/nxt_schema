module NxtSchema
  def new(&block)
    Node::Root.new(nil, nil, {}, &block)
  end

  module_function :new
end
