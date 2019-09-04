module NxtSchema
  module Type
    module Strict
      class Hash < Type::Strict::Base
        HASH_CLASSES = [::Hash, ActiveSupport::HashWithIndifferentAccess]

        def coerce(value)
          return value if value.class.in?(HASH_CLASSES)
          raise_coercion_error(value)
        end
      end
    end

    register :Hash, Type::Strict::Hash
  end
end
