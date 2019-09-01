module NxtSchema
  module Type
    def register(name, type)
      Type::Registry.instance.register(name, type)
    end

    module_function :register
  end
end
