module NxtSchema
  module Template
    class Leaf < Template::Base
      def initialize(name:, type: :String, parent_node:, **options, &block)
        super
      end

      def leaf?
        true
      end
    end
  end
end
