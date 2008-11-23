$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'qtutils'
require 'ics/connection'
require 'ics/protocol'

protocol = ICS::Protocol.new
c = ICS::Connection.new('freechess.org', 5000, protocol)
protocol.add_observer ICS::AuthModule.new(c, 'guest', '')
protocol.add_observer ICS::StartupModule.new(c)
protocol.observe :text do |line|
  puts line
end

# c.debug = true
c.start
while line = gets
  c.send line
end

