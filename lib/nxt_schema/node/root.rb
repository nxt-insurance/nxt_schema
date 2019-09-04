module NxtSchema
  module Node
    class Root < ::NxtSchema::Node::Hash
      def validated?
        @validated ||= false
      end

      def valid?
        if validated?
          errors.reject! { |_,v| v.blank? }
          errors.empty?
        end
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
