module NxtSchema
  module Node
    module Collection
      private

      def initialize_error_stores
        @errors = parent_node.nil? ? {} : parent_node.errors
      end

      def value_violates_emptiness?(value)
        value.empty?
      end
    end
  end
end
