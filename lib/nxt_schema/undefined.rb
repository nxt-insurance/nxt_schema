module NxtSchema
  class Undefined
    def inspect
      self.class.name
    end

    def present?
      false
    end

    def blank?
      true
    end

    def nil?
      true
    end

    alias to_s inspect
  end
end
