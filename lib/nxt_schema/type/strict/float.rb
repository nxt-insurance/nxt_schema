module NxtSchema
  module Type
    module Strict
      class Float < Type::Strict::Base
        def coerce(value)
          coerce_with_kernel_method(value, :Float)
        end
      end

      register :float, Type::Strict::Float
    end
  end
end
