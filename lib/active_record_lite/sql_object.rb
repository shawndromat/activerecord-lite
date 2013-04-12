require_relative './db_connection'
require_relative './mass_object'

class SQLObject < MassObject
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT *
        FROM #{table_name}
    SQL

    results.map { |result| self.new(result) }
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT *
        FROM #{table_name}
       WHERE id = ?
    SQL

    results.map { |result| self.new(result) }.first
  end

  def create
    attr_names = self.class.attributes.join(", ")
    question_marks = (["?"] * self.class.attributes.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO #{self.class.table_name} (#{attr_names}) VALUES (#{question_marks})
    SQL
  end

  def update
    set_line = self.class.attributes.map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE #{self.class.table_name}
         SET #{set_line}
       WHERE id = ?
    SQL
  end

  def save
    if id.nil?
      create
    else
      update
    end
  end

  def attribute_values
    self.class.attributes.map { |attr| self.send(attr) }
  end
end
