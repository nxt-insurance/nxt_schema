module NxtSchema
  module Type
    class Base
      def initialize(name, coercer)
        @name = name
        @coercer = coercer
      end

      def coerce(value)
        coercer.call(value)
      end
    end
  end
end
