#!/usr/bin/env ruby
#
require ‘rubygems‘
require ‘bundler/setup‘
Bundler.require



class Auction < Hash
  before_create :save_to_endpoint

  def save_to_endpoint
    client.new_auction to_fields
  end
end

# 
# class Client
# 
#   def new_auction
# 
#   request :do_check_new_auction_ext, body: { :'session-handle' => $session_hash, :'fields' => $book.to_hash }
#   end
# 
#   # METHODS_TO_ACTIONS = {
#   #   :new_auction => :do_new_auction_ext
#   # }
# 
#   # def method_missing(name, )
#   #   raise "No action for method '#{name}'" if METHODS_TO_ACTIONS[name].nil?
# 
#   #   client.request METHODS_TO_ACTIONS[name], body: ACTIONS_REQUIREMENTS[name] + arg
#   # end
# 
#   # def build_body(parameters)
#   #   required() + parameters
#   # end
# 
# end
