module NxtSchema
  module Node
    class Root < ::NxtSchema::Node::Hash
      def validated?
        @validated ||= false
      end

      def schema_errors?
        schema_errors.any?
      end

      def apply(schema)
        self.schema_errors = { schema_errors_key => [] }
        super(schema, parent_schema_errors: schema_errors).tap do |result|
          @validated = true
          result
        end
      end
    end
  end
end
