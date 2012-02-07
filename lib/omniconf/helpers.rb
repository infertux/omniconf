class Hash
  # Recursive version of Rails' stringify_keys!
  def recursive_stringify_keys!
    self.each do |k, v|
      self[k.to_s] = self.delete(k) unless k.is_a? String
      v.recursive_stringify_keys! if v.is_a? Hash
    end
  end

  def recursive_merge! with_hash
    self.merge!(with_hash) do |key, old_val, new_val|
      return if new_val == old_val
      # XXX This should never happen according to the documentation but for some
      # reason, it does sometimes and outputs false-positive warnings.

      if new_val.is_a?(Hash) && old_val.is_a?(Hash)
        # merge sub-hashes together
        new_val = old_val.recursive_merge! new_val
      else
        # yield block when overriding
        yield key, old_val, new_val if block_given?
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

