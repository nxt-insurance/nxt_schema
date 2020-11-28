module NxtSchema
  module Template
    class TypeSystemResolver
      include NxtInit
      attr_init :node

      delegate_missing_to :node

      def call
        type_system = options.fetch(:type_system) { parent_node&.type_system }

        if type_system.is_a?(Module)
          type_system
        elsif type_system.is_a?(Symbol) || type_system.is_a?(String)
          "NxtSchema::Types::#{type_system.to_s.classify}".constantize
        else
          NxtSchema::Types
        end
      end
    end
  end
end
