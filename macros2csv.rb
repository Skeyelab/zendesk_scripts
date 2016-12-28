require 'rubygems'
require 'bundler/setup'
require 'zendesk_api'
require 'csv'
require 'ruby-progressbar'
require 'dotenv'
require 'pry'
Dotenv.load


client = ZendeskAPI::Client.new do |config|
  config.url = "https://"+ENV["ZD_DOMAIN"]+"/api/v2" # e.g. https://mydesk.zendesk.com/api/v2
  config.username = ENV["ZD_USER"]
  config.token = ENV["ZD_TOKEN"]
  config.retry = true
end


macro_array = []
client.macros.all do |macro|
  row =[]
  row << macro.id

  macro.actions.each do |action|

    if action.field == "comment_value"
      row << action.value
    end
  end
  macro_array << row
end


CSV.open("macros.csv", "wb") do |csv|
  macro_array.each do |row|
    csv << row
  end
end
