require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map{ |key| "#{key} = ?"}
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM 
        #{self.table_name}
      WHERE
        #{where_line.join(" AND ")}
    SQL
    results.map{ |result| self.new(result)}
  end
end

class SQLObject
  extend Searchable
end
