require_relative '04_associatable'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    
    define_method(name) do
      source_options =
            through_options.model_class.assoc_options[source_name]
            
      source_table = "#{source_options.table_name}"
      through_table = "#{through_options.table_name}"
            
      source_join = "#{source_table}.#{source_options.primary_key}"
      through_join = "#{through_table}.#{source_options.foreign_key}"
      
      through_where = "#{through_table}.#{through_options.primary_key}"
      self_where = self.send(through_options.foreign_key)
            
      result = DBConnection.execute(<<-SQL)
      SELECT
        #{source_options.table_name}.*
      FROM
        #{source_options.table_name}
      JOIN
        #{through_options.table_name}
      ON
        #{source_join} = #{through_join}
      WHERE
        #{through_where} = #{self_where}
      SQL
         
      source_options.model_class.new(result.first)
    end
  end
end
