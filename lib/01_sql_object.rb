require_relative 'db_connection'
require 'active_support/inflector'


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
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map { |datum| self.new(datum) }
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    return nil if data.empty?
    self.new(data.first)
    # ...
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=",value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |column_name|
      self.send(column_name)
    end
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(',')
    question_marks = [["?"] * cols.length].join(',')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    cols = self.class.columns.map{ |attr_name| "#{attr_name} = ?"}.drop(1).join(',')
    args = attribute_values.drop(1)

    DBConnection.execute(<<-SQL, *args)
      UPDATE
        #{self.class.table_name}
      SET
        #{cols}
      WHERE
        id = #{self.id}
    SQL
  end

  def save
    if id.nil?
      insert
    else
      update
    end
  end
end
