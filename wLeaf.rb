#!/usr/local/bin/ruby
require 'cinch'
require 'mysql'
sql = Mysql::new("localhost","werring","TWWT","rubyTest")



require './plugin_autovoice.rb'
require './plugin_test.rb'
require './plugin_joinpart.rb'
require './plugin_team.rb'
require './plugin_commands.rb'
require './plugin_znc.rb'
require './plugin_webIface.rb'

require "./team.rb"
@team = Team.new
@team.createTeam

puts "Admins: #{@team.getAdmins}"
puts "Helpers: #{@team.getHelpers}"

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "wLeaf-ruby"
    c.server = "ogn2.onlinegamesnet.net"
    c.port = 6667
    c.password = "tree:TreeFamily"
    c.channels = ["#werring-test"]
    c.messages_per_second = 0.5
    c.realname = "w-test"
    c.server_queue_size=10
    c.plugins.plugins = [
	Autovoice,
	Test,
	JoinPart,
	Teamleden,
	Commands,
	Znc,
	WebIface
	]
  end
end

bot.start
