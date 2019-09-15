module NxtSchema
  module Type
    module Strict
      REGISTRY = Registry.new
      Type.register('strict', REGISTRY)
      delegate :register, :resolve, :resolve_value, to: :REGISTRY
      module_function :register, :resolve, :resolve_value
    end
  end
end
