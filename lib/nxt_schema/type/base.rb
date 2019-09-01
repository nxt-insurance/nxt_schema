module NxtSchema
  module Type
    class Base
      class << self
        def [](value)
          new.coerce(value)
        end
      end

      def coerce_with_kernel_method(method, value)
        # return CoercionError
        value&.tap { |v| Kernel.send(method, v) }
      rescue ArgumentError
        raise CoercionError
      end
    end
  end
end
