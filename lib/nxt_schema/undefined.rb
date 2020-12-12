module NxtSchema
  class Undefined
    def inspect
      self.class.name
    end

    alias to_s inspect
  end
end
