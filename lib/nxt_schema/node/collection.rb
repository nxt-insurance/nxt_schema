module NxtSchema
  module Node
    module Collection
      private

      def initialize_error_stores
        @namespace = resolve_namespace
        @errors = parent_node.nil? ? {} : parent_node.errors
      end
    end
  end
end
