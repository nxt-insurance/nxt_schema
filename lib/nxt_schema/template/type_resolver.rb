module NxtSchema
  module Template
    class TypeResolver
      def resolve(type_system, type)
        @resolve ||= {}
        @resolve[type] ||= begin
          if type.is_a?(Symbol)
            classified_type = type.to_s.classify

            return type_system.const_get(classified_type) if type_system.const_defined?(classified_type)
            return NxtSchema::Types::Nominal.const_get(classified_type) if NxtSchema::Types::Nominal.const_defined?(classified_type)

            NxtSchema::Types.registry(:types).resolve!(type)
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

      def raise_type_not_resolvable_error(type)
        raise ArgumentError, "Can't resolve type: #{type}"
      end
    end
  end
end
