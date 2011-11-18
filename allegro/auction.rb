
module Allegro; end

class Allegro::Auction
  LIFETIME_3DAYS = 0
  LIFETIME_5DAYS = 1
  LIFETIME_7DAYS = 2
  LIFETIME_10DAYS = 3
  LIFETIME_14DAYS = 4

  FIELDS = {
    title: 1,
    category: 2,
    starts_at: 3,
    duration: 4,
    amount: 5,
    buy_now_price: 8,
    country_id: 9,
    region: 10,
    place: 11,
    buyer_pays_for_delivery: 12,
    delivery_methods: 13,
    free_delivery_methods: 35,
    payment_methods: 14,
    description: 24,
    zip_code: 32,
    economic_shipment_price: 36,
    priority_shipment_price: 38,
  }

  FIELDS.each do |name, id|
    define_method(:"#{name}=") do |val|
      @field_values[name] = Allegro::Value.new(val, id)
    end

    define_method(:"#{name}") do
      @field_values[name]
    end
  end

  def initialize
    @field_values = {}
  end

  def to_fields
    fields = []

    # FIELDS.each do |name, id|
      # fields << @field_values[name].to_hash
    # end

    @field_values.each do |name, value|
      fields << value.to_hash
    end

    {:fields => fields}
  end
end
