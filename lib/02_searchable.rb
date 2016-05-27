require_relative 'db_connection'
require_relative '01_sql_object'
require 'byebug'

module Searchable
  def where(params)
    where_line = params.keys.map{|key| "#{key} = ?"}.join(' AND ')
    args = params.values
    #debugger
    data = DBConnection.execute(<<-SQL, *args)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    data.map { |datum| self.new(datum) }
  end
end

class SQLObject
  extend Searchable
end
