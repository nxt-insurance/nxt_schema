module NxtSchema
  module Node
    class Root < ::NxtSchema::Node::Hash
      def validated?
        @validated ||= false
      end

      def valid?
        node_errors.empty?
      end

      def apply(schema)
        self.node_errors = { node_errors_key => [] }
        super(schema, node_errors, {}).tap do |result|
          @validated = true
          result
        end
      end
    end
  end
end
