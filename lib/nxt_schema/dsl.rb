module NxtSchema
  def new(&block)
    Schema.new(nil, nil, {}, &block)
  end

  module_function :new
end
