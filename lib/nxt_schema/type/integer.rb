module NxtSchema
  module Type
    class Integer < Type::Base
      def coerce(value)
        Integer(value)
      end
    end

    register :Integer, Integer
  end
end
