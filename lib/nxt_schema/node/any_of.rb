module NxtSchema
  module Node
    class AnyOf < Base
      include HasSubNodes

      def initialize(name:, type: nil, parent_node:, **options, &block)
        super
      end

      # TODO: Maybe overwrite sub node methods to not have to provide a name here and use node count instead

      def on(*args)
        raise NotImplementedError
      end

      def maybe(*args)
        raise NotImplementedError
      end

      private

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
