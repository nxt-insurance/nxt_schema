module NxtSchema
  module Type
    class Float < Type::Base
      def coerce(value)
        Float(value)
      end
    end

    register :Float, Float
  end
end
