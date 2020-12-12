module NxtSchema
  module Template
    class TypeResolver
      def resolve(type_system, type)
        @resolve ||= {}
        @resolve[type] ||= begin
          if type.is_a?(Symbol)
            resolve_type_from_symbol(type, type_system)
          elsif type.respond_to?(:call)
            type
          else
            raise_type_not_resolvable_error(type)
          end
        rescue NxtRegistry::Errors::KeyNotRegisteredError => error
          raise_type_not_resolvable_error(type)
        end
      end

      private

      def resolve_type_from_symbol(type, type_system)
        classified_type = type.to_s.classify

        return type_system.const_get(classified_type) if type_defined_in_type_system?(type, type_system)
        return NxtSchema::Types::Nominal.const_get(classified_type) if type_defined_in_type_system?(type, NxtSchema::Types::Nominal)

        NxtSchema::Types.registry(:types).resolve!(type)
      end

      def type_defined_in_type_system?(type, type_system)
        type_system.constants.include?(type)
      end

      def raise_type_not_resolvable_error(type)
        raise ArgumentError, "Can't resolve type: #{type}"
      end
    end
  end
end
