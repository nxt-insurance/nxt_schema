module NxtSchema
  module Type
    module Strict
      class Integer < Type::Strict::Base
        def coerce(value)
          coerce_with_kernel_method(value, :Integer)
        end
      end

      register :integer, Type::Strict::Integer
    end
  end
end
