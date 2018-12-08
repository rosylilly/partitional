require 'active_support/concern'
require 'partitional/version'
require 'partitional/validator'

module Partitional
  extend ActiveSupport::Concern

  module ClassMethods
    def partials
      @partials ||= []
    end

    def partial_options
      @partial_options ||= {}
    end

    def partition(name, class_name: nil, mapping: {}, prefix: nil, validation: true)
      name = name.to_s.to_sym
      partials.push(name)

      klass = (class_name || name).to_s.classify.constantize

      klass.attributes.each do |attr|
        mapping[attr] ||= "#{prefix ? "#{prefix}_" : ''}#{attr}"
      end

      partial_options[name] = { mapping: mapping }

      define_partial_accessor(name, klass, mapping)
      define_partial_validator(name, mapping) if validation
    end

    protected

    def define_partial_accessor(name, klass, mapping)
      define_method(name) do
        instance_variable_get(:"@#{name}") ||
          instance_variable_set(:"@#{name}", klass.new(record: self, mapping: mapping))
      end

      define_method(:"#{name}=") do |origin|
        partial = origin.dup
        partial.instance_variable_set(:@record, self)
        partial.instance_variable_set(:@mapping, mapping)
        instance_variable_set(:"@#{name}", partial)
        klass.attributes.each do |attr|
          partial.send(:"#{attr}=", origin.send(attr)) unless mapping[attr].to_s.include?('.')
        end
      end
    end

    def define_partial_validator(name, mapping)
      validates name, partitional: true
    end
  end
end

require 'partitional/model'
