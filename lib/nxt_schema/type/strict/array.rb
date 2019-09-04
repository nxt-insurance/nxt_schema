module NxtSchema
  module Type
    module Strict
      class Array < Type::Strict::Base
        def coerce(value)
          return value if value.is_a?(::Array)
          raise_coercion_error(value)
        end
      end
    end

    register :Array, Type::Strict::Array
  end
end
