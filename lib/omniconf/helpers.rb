class Hash
  # Recursive version of Rails' stringify_keys!
  def recursive_stringify_keys!
    self.keys.each do |key|
      self[key.to_s] = self.delete(key) unless key.is_a? String
      self[key.to_s].recursive_stringify_keys! if self[key.to_s].is_a? Hash
    end
    self
  end

  def recursive_merge! with_hash
    self.merge!(with_hash) do |key, old_val, new_val|
      if new_val.is_a?(Hash) and old_val.is_a?(Hash)
        # merge sub-hashes together
        new_val = old_val.recursive_merge! new_val
      else
        # yield block when overriding
        yield key, old_val, new_val if block_given? and new_val != old_val
      end
      new_val
    end
  end
end

class String
   def demodulize
     self.gsub(/^.*::/, '')
   end
end

