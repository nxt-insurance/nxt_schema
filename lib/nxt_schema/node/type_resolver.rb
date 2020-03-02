module NxtSchema
  module Node
    class TypeResolver
      def resolve(type_system, type)
        @resolve ||= {}
        @resolve[type] ||= begin
          if type.is_a?(Dry::Types::Type)
            type
          else
            # Try to resolve in type system
            type = type_system.const_get(type.to_s.classify)

            if type.is_a?(Dry::Types::Type)
              type
            else
              # in case it does not exist fallback to Types::Nominal
              "NxtSchema::Types::Nominal::#{type.to_s.classify}".constantize
            end
          end
        end
      end
    end
  end
end