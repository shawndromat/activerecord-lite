require_relative './mass_object'
require 'sqlite3'

class DBConnection
  def self.open(db_file_name)
    @db = SQLite3::Database.new(db_file_name)
    @db.results_as_hash = true
    @db.type_translation = true
  end

  def self.execute(*args)
    @db.execute(*args)
  end

  private
  def initialize(db_file_name)
  end
end

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

    results.map { |result| self.new(result) }
  end
end
