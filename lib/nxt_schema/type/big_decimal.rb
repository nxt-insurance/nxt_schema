module NxtSchema
  module Type
    class BigDecimal < Type::Base
      def coerce(value)
        BigDecimal(value)
      end
    end

    register(:BigDecimal, BigDecimal)
  end
end
