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

#declare and array to store macros in
macro_array = []

#loop thru every macro in the desk
client.macros.all do |macro|
  #declaue an array for this particular macro
  row =[]
  #store the macro id into the row
  row << macro.id

  #loop thru each macro.action, looking for the comment_value action
  macro.actions.each do |action|
    if action.field == "comment_value"
      #when we find it, add the action.value to the row
      row << action.value
    end
  end

  #add the individual macro to the macro_array
  macro_array << row
end

#loop thru the macro_array, writing each row to a csv file
CSV.open("macros.csv", "wb") do |csv|
  macro_array.each do |row|
    csv << row
  end
end
