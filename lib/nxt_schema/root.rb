module NxtSchema
  class Root < ::NxtSchema::Node::Hash
    def validated?
      @validated ||= false
    end

    def valid?
      validated? && errors.empty?
    end

    def validate(schema)
      super.tap do |result|
        @validated = true
        result
      end
    end
  end
end
