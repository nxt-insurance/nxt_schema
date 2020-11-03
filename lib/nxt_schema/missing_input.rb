module NxtSchema
  class MissingInput
    def inspect
      self.class.name
    end

    alias to_s inspect
  end
end
