require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

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
    options = BelongsToOptions.new(name, options)

    define_method(options.class_name.downcase.to_sym) do
      fk = options.send(:foreign_key)
      fk_val = self.send("#{fk}")
      return nil if fk_val.nil?

      data = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          id = #{fk_val}
      SQL
      options.model_class.new(data.first)
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, options)

    define_method(options.class_name.downcase.pluralize.to_sym) do
      fk = options.send(:foreign_key)
      pk_val = self.send(options.send(:primary_key))
      #debugger
      if fk.to_s.length > 10
        fk = fk.to_s.split(':')[2][0..-5].to_sym
      end
      return nil if pk_val.nil?

      data = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{fk} = #{pk_val}
      SQL
      data.map{|datum| options.model_class.new(datum)}
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
