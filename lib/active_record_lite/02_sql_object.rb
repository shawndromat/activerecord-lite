require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'
require_relative '00_attr_accessor_object.rb'


class MassObject < AttrAccessorObject
  # def self.parse_all(results)
  #   results.each_with_index do |result, i|
  #     a = self.new(result)
  #     p a
  #     results[i] = a
  #   end
  # end
end

class SQLObject < MassObject
  
  def self.columns
    if @columns.nil?
      results = DBConnection.execute2(<<-SQL)
        SELECT 
          *
        FROM 
          #{self.table_name}
      SQL
      @columns = results[0].map(&:to_sym)
      attr_accessor(*@columns)
    else
      @columns
    end
  end
  
  def self.attr_accessor(*names)
    names.each do |name|
      define_method(name) do
        @attributes[name.to_s]
      end
      
      define_method("#{name}=") do |argument|
        @attributes[name.to_s] = argument
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.underscore.downcase
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    
    results.map{ |result| self.new(result) }
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
      #{self.table_name}.id = ?
    SQL
    self.new(result[0])
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    
    query = <<-SQL
      INSERT INTO #{self.class.table_name} 
        (#{cols_without_id.map(&:to_s).join(', ')})
      VALUES 
        (#{("?" * cols_without_id.length).split("").join(", ")})
    SQL

    DBConnection.execute(query, *vals_without_id)
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    attrs = {}
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute '#{attr_name}'"
      end
      instance_variable_set("@#{attr_name}", value)
      attrs[attr_name] = value
      @attributes = attrs
    end
  end

  def save 
    if attributes["id"] == nil
      insert
    else
      update
    end
  end

  def update
    update_string =[]
    cols_without_id.each do |col|
      update_string << "#{col} = ?"
    end
    
    query = <<-SQL
      UPDATE #{self.class.table_name}
      SET #{update_string.join(", ")}
      WHERE id = #{self.id}
    SQL
    DBConnection.execute(query, *vals_without_id)
  end

  def attribute_values
    @attributes.values
  end
  
  def cols_without_id
    @attributes.reject{ |attr_name, _| attr_name == :id}.keys
  end
  
  def vals_without_id
    @attributes.reject{ |attr_name, value| attr_name == :id}.values
  end
end



