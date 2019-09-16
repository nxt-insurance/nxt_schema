module NxtSchema
  module Type
    module Strict
      class Base
        class << self
          def [](value)
            new.coerce(value)
          end
        end

        def initialize(default: nil, maybe: nil)
          @default = default
          @maybe = maybe
        end

        def coerce_with_kernel_method(value, method)
          raise_coercion_error(value) unless value.is_a?(Object.const_get(method))
          value&.tap { |v| Kernel.send(method, v) }
        rescue ArgumentError
          raise_coercion_error(value)
        end

        private

        def raise_coercion_error(value)
          raise NxtSchema::Errors::CoercionError.new(value, self)
        end
      end
    end
  end
end
