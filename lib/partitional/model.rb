require 'active_model'

module Partitional
  class Model
    include ActiveModel::Model

    attr_accessor :record
    attr_writer :mapping

    def self.attributes
      @attributes ||= []
    end

    def self.attr_define(*attrs)
      attributes.concat(attrs.map(&:to_sym))
      attributes.uniq!
    end

    def self.attr_reader(*attrs)
      attr_define(*attrs)
      attrs.each do |attr|
        attr = attr.to_s.to_sym
        define_method(attr) do
          self[attr]
        end
      end
    end

    def self.attr_writer(*attrs)
      attr_define(*attrs)
      attrs.each do |attr|
        attr = attr.to_s.to_sym
        define_method(:"#{attr}=") do |val|
          self[attr] = val
        end
      end
    end

    def self.attr_accessor(*attrs)
      attr_reader(*attrs)
      attr_writer(*attrs)
    end

    def [](attr)
      attr = attr.to_s.to_sym
      reader = mapping.fetch(attr) { attr }
      record ? record_send(reader) : instance_variable_get(:"@#{attr}")
    end

    def []=(attr, val)
      attr = attr.to_s.to_sym
      writer = mapping.fetch(attr) { attr }
      record ? record_send(:"#{writer}=", val) : instance_variable_set(:"@#{attr}", val)
    end

    def as_json
      attrs = self.class.attributes.map do |key|
        [key, send(key)]
      end

      Hash[attrs]
    end

    def mapping
      @mapping || {}
    end

    protected

    def record_send(method, *args)
      methods = method.to_s.split('.')
      actual = methods.pop
      rec = methods.inject(record) do |receiver, m|
        receiver.send(m)
      end

      rec.send(actual, *args)
    end
  end
end
