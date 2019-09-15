module NxtSchema
  module Type
    REGISTRY = Registry.new
    delegate :register, :resolve, :resolve_value, to: :REGISTRY
    module_function :register, :resolve, :resolve_value
  end
end
