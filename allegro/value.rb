
module Allegro; end

class Allegro::Value
  CLASS_TO_TYPE = {
    String     => :string,
    Integer    => :int,
    Fixnum     => :int,
    Float      => :float,
    File       => :image,
    Time       => :datetime,
    TrueClass  => :boolean,
    FalseClass => :boolean,
  }  

  CONVERTERS = {
    datetime: ->(date){ date.to_i }
  }
  
  EMPTY_HASH = {
    'fid'             => nil,
    'fvalue-string'   => '',
    'fvalue-int'      => 0,
    'fvalue-float'    => 0,
    'fvalue-image'    => ' ',
    'fvalue-datetime' => 0,
    'fvalue-boolean'  => false,
  }

  def initialize(value, field_id)
    @value = value
    @field_id = field_id
  end

  def type_of_value
    raise "Invalid type: #{@value.class}" unless CLASS_TO_TYPE.include? @value.class

    CLASS_TO_TYPE[@value.class]
  end

  def class_of_value
    @value.class
  end

  def to_hash
    hash = EMPTY_HASH.dup
    hash['fid'] = @field_id

    converted = CONVERTERS[type_of_value].nil? ? @value : CONVERTERS[type_of_value].call(@value)
    hash["fvalue-#{type_of_value}"] = converted
    
    hash
  end
end
