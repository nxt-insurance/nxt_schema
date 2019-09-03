module NxtSchema
  module Node
    class Root < ::NxtSchema::Node::Hash
      def validated?
        @validated ||= false
      end

      def valid?
        validated? && errors.empty?
      end

      def apply(schema)
        super.tap do |result|
          @validated = true
          result
        end
      end
    end
  end
end
