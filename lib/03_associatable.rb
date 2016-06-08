require_relative '02_searchable'
require 'active_support/inflector'


# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    table = class_name.pluralize.downcase.to_s
    table == 'humen' ? 'humans' : table
  end

end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    default = {class_name: name.to_s.classify,
              foreign_key: "#{name.to_s.singularize.downcase}_id".to_sym,
              primary_key: :id}

    options = default.merge(options)

    options.each do |key, value|
      next if value.nil?
      value = value.to_sym unless key == :class_name
      self.instance_variable_set("@#{key}", value)
    end

  end
end

#self_class_name.values.first
class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    default = {class_name: name.to_s.classify,
              foreign_key: "#{self_class_name.to_s.singularize.downcase}_id".to_sym,
              primary_key: :id}

    options = default.merge(options)

    options.each do |key, value|
      next if value.nil?
      value = value.to_sym unless key == :class_name
      self.instance_variable_set("@#{key}", value)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.foreign_key)
      options
        .model_class
        .where(options.primary_key => key_val)
        .first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.primary_key)
      options
        .model_class
        .where(options.foreign_key => key_val)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
    @assoc_options ||= {}
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
