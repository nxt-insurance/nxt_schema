module NxtSchema
  def new(&block)
    Schema.new(:root, nil, {}, &block)
  end

  module_function :new
end
