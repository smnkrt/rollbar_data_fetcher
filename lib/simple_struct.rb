# frozen_string_literal: true

class SimpleStruct
  def initialize(hash = {})
    @hash = {}
    hash.each { |k, v| self.[]=(k, v) }
  end

  def []=(key, val)
    @hash[key] = val
    define_singleton_method(key) { @hash[key] }
  end

  def [](key)
    @hash.fetch(key)
  end

  def to_h
    @hash
  end
end