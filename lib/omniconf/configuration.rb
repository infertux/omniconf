require 'omniconf/blank_state'

module Omniconf
  class Configuration < BlankSlate
    # XXX: Every method defined in this class overrides config value accessors,
    # hence it inherits from BlankSlate (and the gross 'method_missing')

    def initialize(adapter, table = {}, parent = nil)
      @__adapter, @__parent = adapter, parent
      @__table = table.recursive_stringify_keys!
    end

    # Helpful helper which returns the object as a hash
    def to_hash
      @__table
    end

    def get_or_default(key, default)
      raise "key cannot be nested" if key.include? '.'
      __send__ :"#{key}=", default unless value = __send__(:"#{key}")
      value || default
    end

    def method_missing(method, *args)
      raise NoMethodError, "undefined method `#{method}' for #{self}" \
        if method.to_s[0..1] == '__' # will save hours tracking down heisenbugs

      len = args.length
      if new_key = method.to_s.chomp!('=') # write
        if len == 1
          key, value = new_key, args[0]
        else
          raise ArgumentError, "wrong number of arguments (#{len} for 1)"
        end

        key = key.to_s # stringify keys

        if @__adapter # should not be nil expect for testing purposes
          # update the actual source data (e.g. does the SQL query)
          full_key, parent = [key], @__parent
          while parent # build the full nested key from parents
            full_key = full_key.unshift parent[:root]
            parent = parent[:object].__parent
          end

          @__adapter.set_value(full_key, value) # notify the adapter
        else
          Omniconf.logger.warn "No adapter to notify"
        end

        @__table[key] = value # update our internal config hash

        if @__adapter.is_a? Omniconf::Adapter::Base
          # we need to merge the global config
          Omniconf.merge_configuration! @__adapter.source_id
        end

      elsif len == 0 # dotted read
        key = method.to_s
        value = @__table[key]
        if value.is_a?(Hash)
          Configuration.new(@__adapter, value, {:root => key, :object => self})
        else
          unless value
            # add a catch-all exception
            # (more descriptive than "undefined method `xxx' for nil:NilClass")
            class << value
              def method_missing *args
                raise UnknownConfigurationValue,
                      "cannot get a configuration value with no parent"
              end
            end
          end
          value
        end

      else
        raise NoMethodError, "undefined method `#{method}' for #{self}"
      end
    end

    protected
    attr_reader :__parent

    private
    attr_reader :__table
  end
end

