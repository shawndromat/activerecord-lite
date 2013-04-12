require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

module Associatable
  def belongs_to(name, params = {})
    define_method(name) do
      other_class = params[:class_name].try(:constantize) ||
        name.to_s.camelcase.constantize
      other_table_name = other_class.table_name
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{name}_id".to_sym

      results = DBConnection.execute(<<-SQL, self.send(foreign_key))
        SELECT *
          FROM #{other_table_name}
         WHERE #{other_table_name}.#{primary_key} = ?
      SQL

      other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
    define_method(name) do
      other_class = params[:class_name].try(:constantize) ||
        name.to_s.singularize.camelcase.constantize
      other_table_name = other_class.table_name
      primary_key = params[:primary_key] || :id
      foreign_key = params[:foreign_key] || "#{self.class.name.underscore}_id".to_sym

      results = DBConnection.execute(<<-SQL, self.send(primary_key))
        SELECT *
          FROM #{other_table_name}
         WHERE #{other_table_name}.#{foreign_key} = ?
      SQL

      other_class.parse_all(results)
    end
  end
end
