module NxtSchema
  def new(&block)
    Root.new(nil, nil, {}, &block)
  end

  module_function :new
end
