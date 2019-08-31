require_relative 'registry'

[Integer, String, Float, BigDecimal].each do |type|
  NxtSchema::Type::Registry.instance.register_type(type.to_sym) do |value|
    Kernel.send(type, value)
  end
end

[Array, Hash].each do |type|
  NxtSchema::Type::Registry.instance.register_type(type.to_sym) do |value|
    raise ArgumentError, "#{value} is not of type: #{type}" unless value.is_a?(type)
  end
end

NxtSchema::Type::Registry.instance.register_type(:email) do |value|
  unless String(value).match(/\A.*@.*\z/)
    raise ArgumentError, "#{value} is not of type: #{type}"
  end
end

NxtSchema::Type::Registry.instance.register_type(:bool) do |value|
  if value.in?([false, 'false', '0', 0])
    false
  elsif value.in?([true, 'true', '1', 1])
    true
  else
    raise ArgumentError, "#{value} does not seem to be of type: Boolean"
  end
end


