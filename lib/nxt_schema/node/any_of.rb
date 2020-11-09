module NxtSchema
  module Node
    class AnyOf < Base
      include HasSubNodes

      def initialize(name:, type: nil, parent_node:, **options, &block)
        super
      end

      # TODO: Maybe overwrite sub node methods to not have to provide a name here and use node count instead
      # TODO: We should not allow to call :on and :maybe on any_of nodes!

      private

      def resolve_type(name_or_type)
        # no opt
      end

      def resolve_optional_option
        # TODO: raise if optional is passed here?!
      end

      def resolve_omnipresent_option
        # TODO: raise if omni present is passed here?!
      end
    end
  end
end
