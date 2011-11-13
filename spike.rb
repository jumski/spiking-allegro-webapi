# encoding: utf-8
require 'savon'
require 'active_support'
require 'yaml'
load './allegro/client.rb'
load './allegro/value.rb'
load './allegro/auction.rb'
require './credentials.rb'

COUNTRY_CODE = 228 # testwebapi.pl
VERSION_KEY = '66133613'

$c = AllegroClient.new(COUNTRY_CODE, VERSION_KEY, WEBAPI_KEY, LOGIN, PASSWORD)

def get_raw_fields
  path = 'tmp/get_raw_fields.dump'
  if File.exists?(path)
    fields = Marshal::load File.open(path).read
  else
    results = $c.request :do_get_sell_form_fields_for_category, body: {
      'webapi-key' => WEBAPI_KEY,
      'country-id' => COUNTRY_CODE,
      'category-id' => 1829,
    }

    fields = results.body.first.last[:sell_form_fields_for_category][:sell_form_fields_list][:item]

    File.open(path, 'w') do |f|
      f.write Marshal::dump(fields)
    end
  end

  fields
end

def get_fields
  fields ||= get_raw_fields.collect do |field|
    new = {}

    field.each do |key, value|
      next unless key.to_s =~ /sell_form_/
      simple_key = key.to_s.sub(/sell_form_/, '').to_sym
      new[simple_key] = value
    end
    
    new
  end

  fields
end

def find_field(id)
  get_fields.select{|f| f[:id].to_i == id.to_i }.first
end

def search_field(text)
  get_fields.select{|f| f[:title] =~ /#{text}/ }.first
end

def show_fields(filter = nil)
  get_fields.each do |f|
    puts "[#{f[:id]}] #{f[:title]}"
  end
  return
end


$book = Allegro::Auction.new

LIFETIME_3DAYS = 0
LIFETIME_5DAYS = 1
LIFETIME_7DAYS = 2
LIFETIME_10DAYS = 3
LIFETIME_14DAYS = 4

$book.name = 'Pan Tadeusz' 
$book.category = 1829
$book.amount = 1
$book.buy_now_price = 123.45
$book.duration = LIFETIME_7DAYS
$book.description = %Q{
<h2>Pan tadeusz!</h2>
kup teraz ~!!!!!!<br/>
nie odwoluje aukcji
}

$book.seller_pays_for_delivery = 0
$book.country_id = 228
$book.region = 213
$book.place = "krakuf"
$book.zip_code = "31-331"

# $book.starts_at = Time.now
$book.delivery_methods = 1
$book.shipment_price = 0.0
$book.payment_methods = 1

$c.make_auction $book
