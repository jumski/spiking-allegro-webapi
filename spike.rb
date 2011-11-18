# encoding: utf-8
require 'pry'
require 'savon'
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
$book.title = 'Frywolna Filozofia' 
$book.category = 1829
$book.amount = 1
$book.buy_now_price = 23.50
$book.duration = Allegro::Auction::LIFETIME_7DAYS
$book.description = %Q{
<h2>Frywolna filozofia</h2>
asldfasdklfhaskl;dfhasjkldhfklasdf
asdfasd
fsadfs
adfasd
fasdfsdfasd
fasdfasdf
}

$book.buyer_pays_for_delivery = 1
$book.country_id = 228
$book.region = 213
$book.place = "krakuf"
$book.zip_code = "31-331"

$book.delivery_methods = 1 + 2
$book.economic_shipment_price = 2.35
$book.priority_shipment_price = 5.23
$book.payment_methods = 1
$book.free_delivery_methods = 1

def commit_auction
  response = $c.make_auction $book
  item_id = response.body[:do_new_auction_ext_response][:item_id]
end

binding.pry
