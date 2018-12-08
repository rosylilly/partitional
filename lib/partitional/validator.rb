require 'active_model'

class PartitionalValidator < ActiveModel::EachValidator
  ALLOWED_OPTIONS = %i[
    allow_nil
    allow_blank
    if
    unless
    message
    attributes
  ]

  def check_validity!
    invalid_keys = []
    options.except(*ALLOWED_OPTIONS).each_pair do |key, value|
      invalid_keys.push("#{key}: #{value}")
    end
    raise ArgumentError, "#{invalid_keys.join(', ')} is invalid options." unless invalid_keys.empty?
  end

  def validate_each(record, attribute, value)
    return if options[:if].present? && !to_value(record, options[:if])
    return if options[:unless].present? && to_value(record, options[:unless])

    value.validate
    mapping = value.mapping

    value.errors.each do |attr, message|
      record.errors.add(mapping[attr], message)
    end
  end

  protected

  def to_value(record, value)
    return record.send(value) if value.is_a?(Symbol)
    return value.call(record) if value.is_a?(Proc)
    value
  end
end
