module NxtSchema
  module Type
    module Strict
      class Boolean < Type::Strict::Base
        TRUE_VALUES = [true, 1]
        FALSE_VALUES = [false, 0]

        def coerce(value)
          return true if value.in?(TRUE_VALUES)
          return false if value.in?(FALSE_VALUES)
          raise_coercion_error(value)
        end
      end

      register :boolean, Type::Strict::Boolean
    end
  end
end
