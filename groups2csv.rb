require 'rubygems'
require 'bundler/setup'
require 'zendesk_api'
require 'csv'
require 'ruby-progressbar'
require 'dotenv'
Dotenv.load


client = ZendeskAPI::Client.new do |config|

  config.url = "https://"+ENV["ZD_DOMAIN"]+"/api/v2" # e.g. https://mydesk.zendesk.com/api/v2


  config.username = ENV["ZD_USER"]

  config.token = ENV["ZD_TOKEN"]

  config.retry = true

end


grps = {}
emails = {}
grplist = []
data =[]
users =[]



progressbar = ProgressBar.create(:title=>"Gathering agent IDs",:starting_at => 0, :total => 3, :format         => '%a %bᗧ%i %p%% %t',
                                 :progress_mark  => ' ',
                                 :remainder_mark => '･')

roles = ["admin","agent"]

roles.each do |role|
  client.users.search(:role => role).all do |agent|
    users << agent.id
  end
  progressbar.increment

end
progressbar.finish

users = users.sort

progressbar = ProgressBar.create(:title=>"Gathering groups",:starting_at => 0, :total => users.count,:format         => '%a %bᗧ%i %p%% %t',
                                 :progress_mark  => ' ',
                                 :remainder_mark => '･')

users.each do |user|
  u = client.users.find(:id=>user)
  emails[u.email]=[]

  progressbar.log u.email


  u.groups.each do |group|

    if !grps.has_key?(group.name)
      grps[group.name] = []
      grplist << group.name
    end
    grps[group.name] << u.email
    emails[u.email] << group.name

  end
  progressbar.increment

end

grplist = grplist.sort
progressbar = ProgressBar.create(:title=>"Writing CSV",:starting_at => 0, :total => grplist.count)

CSV.open("output/out.csv", "wb") do |csv|
  row =["email"]
  grplist.each do |grp|
    row << grp
  end
  data << grplist
  csv << row
  emails.each do |email,v|

    row =[]
    row << email
    grplist.each do |grp|
      if grps[grp].include? email
        row << "X"
      else
        row << " "
      end
    end
    data << row
    csv << row
    progressbar.increment
  end
  progressbar.finish
end
