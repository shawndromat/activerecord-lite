require_relative './db_connection'

module Searchable
  def where(params)
    where_line = params.map { |key, val| "#{key} = ?" }.join(", ")

    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT *
        FROM #{table_name}
       WHERE #{where_line}
    SQL

    parse_all(results)
  end
end
