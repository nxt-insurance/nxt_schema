module NxtSchema
  module Template
    class AnyOf < Base
      include HasSubNodes

      def initialize(name:, type: nil, parent_node:, **options, &block)
        super
        ensure_sub_nodes_present
      end

      def collection(name = sub_nodes.count, type: NxtSchema::Template::Collection::DEFAULT_TYPE, **options, &block)
        super
      end

      def schema(name = sub_nodes.count, type: NxtSchema::Template::Schema::DEFAULT_TYPE, **options, &block)
        super
      end

      def node(name = sub_nodes.count, node_or_type_of_node: Undefined.new, **options, &block)
        super
      end

      def on(*args)
        raise NotImplementedError
      end

      def maybe(*args)
        raise NotImplementedError
      end

      private

      def typed?
        true # we do not have to type this
      end

      def resolve_type(name_or_type)
        nil
      end

      def resolve_optional_option
        return unless options.key?(:optional)

        raise InvalidOptions, "The optional option is not available for nodes of type #{self.class.name}"
      end

      def resolve_omnipresent_option
        return unless options.key?(:omnipresent)

        raise InvalidOptions, "The omnipresent option is not available for nodes of type #{self.class.name}"
      end
    end
  end
end
