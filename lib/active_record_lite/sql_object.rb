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
end
