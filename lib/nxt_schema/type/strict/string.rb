module NxtSchema
  module Type
    module Strict
      class String < Type::Strict::Base
        def coerce(value)
          coerce_with_kernel_method(value, :String)
        end
      end
    end

    register :String, Type::Strict::String
  end
end
