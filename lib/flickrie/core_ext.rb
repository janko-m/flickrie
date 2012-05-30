class Hash
  def deep_merge!(other_hash)
    other_hash.each_pair do |k,v|
      tv = self[k]
      self[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? tv.deep_merge(v) : v
    end
    self
  end

  def deep_merge(other_hash)
    dup.deep_merge!(other_hash)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end

  def except(*keys)
    self.dup.except!(*keys)
  end
end
