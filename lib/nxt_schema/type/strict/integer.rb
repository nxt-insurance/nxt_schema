module NxtSchema
  module Type
    module Strict
      class Integer < Type::Strict::Base
        def coerce(value)
          coerce_with_kernel_method(value, :Integer)
        end
      end
    end

    register :Integer, Type::Strict::Integer
  end
end
