$:.unshift(File.join(File.dirname(__FILE__), '..'))
require 'qtutils'
require 'ics/connection'
require 'ics/protocol'

protocol = ICS::Protocol.new
c = ICS::Connection.new('freechess.org', 5000, protocol)
protocol.add_observer ICS::AuthModule.new(c, 'guest', '')
protocol.observe :text do |line|
  puts line
end
protocol.observe :prompt do |p|
  print p
end

c.start
while line = gets
  c.send line
end

