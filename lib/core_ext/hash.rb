class Hash
  def dig(*args)
    value = self[args.shift]
    return value if value.nil? || args.count.zero?
    value.is_a?(Hash) ? value.dig(*args) : nil
  end
end
