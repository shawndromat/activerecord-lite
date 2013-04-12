require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

module Associatable
  def belongs_to(name, params = {})
    full_params = {
      :other_class_name => params[:class_name] || name.to_s.camelcase,
           :primary_key => params[:primary_key] || :id,
           :foreign_key => params[:foreign_key] || "#{name}_id".to_sym,
                  :type => :belongs_to
    }

    @assoc_params ||= {}
    @assoc_params[name] = full_params

    define_method(name) do
      other_class = full_params[:other_class_name].constantize
      other_table_name = other_class.table_name
      primary_key = full_params[:primary_key]
      foreign_key = full_params[:foreign_key]

      results = DBConnection.execute(<<-SQL, self.send(foreign_key))
        SELECT *
          FROM #{other_table_name}
         WHERE #{other_table_name}.#{primary_key} = ?
      SQL

      other_class.parse_all(results).first
    end
  end

  def has_many(name, params = {})
    full_params = {
      :other_class_name => (params[:class_name] ||
                              name.to_s.singularize.camelcase),
           :primary_key => params[:primary_key] || :id,
           :foreign_key => (params[:foreign_key] ||
                              "#{self.name.underscore}_id".to_sym),
                  :type => :has_many
    }

    @assoc_params ||= {}
    @assoc_params[name] = full_params

    define_method(name) do
      other_class = full_params[:other_class_name].constantize
      other_table_name = other_class.table_name
      primary_key = full_params[:primary_key]
      foreign_key = full_params[:foreign_key]

      results = DBConnection.execute(<<-SQL, self.send(primary_key))
        SELECT *
          FROM #{other_table_name}
         WHERE #{other_table_name}.#{foreign_key} = ?
      SQL

      other_class.parse_all(results)
    end
  end
end
