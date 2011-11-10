
module Allegro; end

class Allegro::Auction
  FIELDS = {
    :name      => { :id => 1, :type => :string },
    :category  => { :id => 2, :type => :int },
    :starts_at => { :id => 3, :type => :datetime },
    :duration  => { :id => 4, :type => :integer },
    :amount    => { :id => 5, :type => :integer },
    :buy_now_price => { :id => 8, :type => :float },
    :country_id => { :id => 9, :type => :integer },
    :region    => { :id => 10, :type => :integer },
    :place     => { :id => 11, :type => :integer },
    :buyer_pays_for_delivery => { :id => 12, :type => :boolean },
    :delivery_methods => { :id => 13, :type => :integer },
    :payment_methods  => { :id => 14, :type => :integer },
    :description => { :id => 24, :type => :string },
    :zip_code => { :id => 32, :type => :string },
  }

  FIELDS.each do |name, opts|
    define_method(:"#{name}=") do |val|
      @field_values[name] = Allegro::Value.new(val, opts[:id])
    end
  end

  def initialize
    @field_values = {}

    # country id -> testwebapi.pl
    # country_id = 228
    # @field_values << Allegro::Value.new(228, 9)
  end

  def to_hash
    hash = {}
    hash['fields'] = []

    FIELDS.each do |name, opts|
      value = @field_values[name].to_hash
      hash['fields'] << @field_values[name].to_hash
    end

    hash
  end

end
