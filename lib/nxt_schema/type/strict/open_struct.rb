module NxtSchema
  module Type
    module Strict
      class OpenStruct < Type::Strict::Base
        HASH_CLASSES = [::Hash, ActiveSupport::HashWithIndifferentAccess]

        def coerce(value)
          if value.class.in?(HASH_CLASSES)
            result = ::OpenStruct.new(value)
            p result
            return result
          end

          raise_coercion_error(value)
        end
      end

      register :struct, Type::Strict::OpenStruct
    end
  end
end
