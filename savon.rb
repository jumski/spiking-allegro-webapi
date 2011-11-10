#!/usr/bin/env ruby
# encoding: utf-8
require 'savon'
require './allegro/value.rb'
require './allegro/auction.rb'

class AllegroClient < Savon::Client
  def initialize
    super() do
      wsdl.document = 'allegro.wsdl'
    end
    # super "http://webapi.allegro.pl/uploader.php?wsdl"
    # super "http://www.testwebapi.pl/uploader.php?wsdl"
  end
end

class SwistakClient < Savon::Client
  def initialize
    super() do
      wsdl.document = 'swistak.wsdl'
    end
  end

  def authenticate(login, pass)
    # request :get_hash, body: [ login, pass ]
  end
end

require './credentials.rb'
WEBAPI_KEY = '3870701153'
COUNTRY_CODE = 228
VERSION_KEY = '66133613'

$login_body = {
  :"user-login"    => LOGIN,
  :"user-password" => PASSWORD,
  :"country-code"  => COUNTRY_CODE,
  :"webapi-key"    => WEBAPI_KEY,
  :"local-version" => VERSION_KEY
}

$c = AllegroClient.new
def login
  $login_response = $c.request :do_login, body: $login_body
  $session_hash = $login_response.to_hash[:do_login_response][:session_handle_part]
end

def get_raw_fields
  results = $c.request :do_get_sell_form_fields_for_category, body: {
    'webapi-key' => WEBAPI_KEY,
    'country-id' => COUNTRY_CODE,
    'category-id' => 1829,
  }

  results.body.first.last[:sell_form_fields_for_category][:sell_form_fields_list][:item]
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

def get_optional_fields
  get_fields.select{|f| f[:sell_form_opt].to_i == 8}
end

def get_required_fields
  get_fields.select{|f| f[:sell_form_opt].to_i == 1}
end

def find_field(id)
  get_fields.select{|f| f[:id].to_i == id.to_i }.first
end


$book = Allegro::Auction.new

LIFETIME_3DAYS = 0
LIFETIME_5DAYS = 1
LIFETIME_7DAYS = 2
LIFETIME_10DAYS = 3
LIFETIME_14DAYS = 4

$book.name = 'Pan Tadeusz' 
$book.category = '1829'
$book.starts_at = Time.now
$book.duration = LIFETIME_7DAYS
$book.amount = 1
$book.buy_now_price = 123.45
$book.country_id = 228
$book.region = 213
$book.place = "krakuf"
$book.zip_code = "31-331"
$book.buyer_pays_for_delivery = true
$book.delivery_methods = 1
$book.payment_methods = 1
$book.description = <<HTML
<h2>Pan tadeusz!</h2>
kup teraz ~!!!!!!<br/>
nie odwoluje aukcji
HTML

def make_auction
  a=$c.request :do_check_new_auction_ext, body: { :'session-handle' => $session_hash, :'fields' => $book.to_hash }
end

