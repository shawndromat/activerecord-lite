require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @name = name.to_s
    @foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    @class_name = options[:class_name] || @name.classify
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name.to_s
    @foreign_key = options[:foreign_key] || 
                    "#{self_class_name.downcase}_id".to_sym
    @class_name = options[:class_name] || @name.singularize.classify
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    
    define_method(name) do
      options.model_class.where(options.primary_key => send(options.foreign_key))[0]
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)
    define_method(name) do
      options.model_class.where(options.foreign_key => send(options.primary_key))
    end
  end

  def assoc_options
    if @assoc_params == nil
      @assoc_params = {}
    else
      @assoc_params
    end
  end
end

class SQLObject
  extend Associatable
end