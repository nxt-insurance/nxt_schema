module NxtSchema
  module Type
    module Strict
      class BigDecimal < Type::Strict::Base
        def coerce(value)
          coerce_with_kernel_method(value, :BigDecimal)
        end
      end
    end

    register(:BigDecimal, Type::Strict::BigDecimal)
  end
end
