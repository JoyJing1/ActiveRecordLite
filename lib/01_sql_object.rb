require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    @columns ||= []
    if @columns.empty?
      data = DBConnection.execute2(<<-SQL)
        SELECT
          *
        FROM
          #{table_name}
      SQL
      @columns = data.first.map {|col_name| col_name.to_sym}
    end
    @columns
  end

  def self.finalize!
    columns.each do |column_name|
      define_method("#{column_name}") do
        attributes[column_name.to_sym]
      end

      define_method("#{column_name}=") do |value|
        attributes[column_name.to_sym] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = self.table_name
  end

  def self.table_name
    name = "#{self}".tableize
    if name == 'humen'
      'humans'
    else
      name
    end
  end

  def self.all
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})
    #self.class.finalize!
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      #debugger
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute #{attr_name}"
      end

      #debugger
      #Correct syntax for method?
      self.send("#{attr_name}=('#{value}')")

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
