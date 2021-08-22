module NxtSchema
  class Undefined
    def inspect
      self.class.name
    end

    def present?
      false
    end

    alias to_s inspect
  end
end
