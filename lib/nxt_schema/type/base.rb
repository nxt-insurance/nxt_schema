module NxtSchema
  module Type
    class Base
      class << self
        def [](value)
          new.coerce(value)
        end
      end

      def coerce_with_kernel_method(method, value)
        raise_coercion_error(value) if value.nil?
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
