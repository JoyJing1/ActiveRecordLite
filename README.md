# ActiveRecordLite

Active Record Lite is an academic exercise in re-building the fundamental components of Active Record and implementing its object-relational mapping (ORM) pattern.

The purpose was to deeply understand how ActiveRecord works, with a focus on how it translates associations and queries into SQL code. It is written in pure Ruby.

## Code Snippets

### where
```ruby
def where(params)
  where_line = params.keys.map{|key| "#{key} = ?"}.join(' AND ')
  args = params.values

  data = DBConnection.execute(<<-SQL, *args)
    SELECT
      *
    FROM
      #{table_name}
    WHERE
      #{where_line}
  SQL
  data.map { |datum| self.new(datum) }
end
```

### update
```ruby
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
```

### has_many
```ruby
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
```

### has_one_through
```ruby
def has_one_through(name, through_name, source_name)
  define_method(name) do
    through_options = self.class.assoc_options[through_name]
    source_options = through_options.model_class.assoc_options[source_name]

    through_table = through_options.table_name
    through_pk = through_options.primary_key
    through_fk = through_options.foreign_key

    source_table = source_options.table_name
    source_pk = source_options.primary_key
    source_fk = source_options.foreign_key

    key_val = self.send(through_fk)

    results = DBConnection.execute(<<-SQL, key_val)
      SELECT
        #{source_table}.*
      FROM
        #{through_table}
      JOIN
        #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
      WHERE
        #{through_table}.#{through_pk} = ?
    SQL

    source_options.model_class.parse_all(results).first
  end
end
```
