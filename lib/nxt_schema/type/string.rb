module NxtSchema
  module Type
    class String < Type::Base
      def coerce(value)
        coerce_with_kernel_method(:String, value)
      end
    end

    register :String, String
  end
end
