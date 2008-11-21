require 'observer_utils'

module ICS

class Protocol
  include Observable
  @@last_action = nil
  @@actions = []
  @@partial_actions = []

  def self.on(regex, type = :full, &blk)
    # ugly hack to work around the missing
    # instance_exec in ruby 1.8
    mname = "__action_#{regex.to_s}"
    if type == :partial
      @@partial_actions << [mname, regex]
    else type == :full
      @@actions << [mname, regex]
    end
    define_method mname, &blk
  end

  def process(line)
    execute_action @@actions, line
  end

  def process_partial(line)
    execute_action @@partial_actions, line
  end

  on %r{^Creating:\s+(\S+)\s+\((\S*)\)\s+(\S+)\s+\((\S*)\)
     \s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)}x do |match|
    fire :create_game => {
      :white => { 
        :name => match[1],
        :score => match[2].to_i },
      :black => {
        :name => match[3],
        :score => match[4].to_i },
      :rated => match[5],
      :type => match[6],
      :time => match[7].to_i,
      :increment => match[8].to_i }
  end

  on /^login:/, :partial do
    fire :login_prompt
  end
  
  on /^password:/, :partial do
    fire :password_prompt
  end

  on /^Press return/ do
    fire :press_return_prompt
  end

  private
  
  def execute_action(actions, line)
    actions.each do |action, regex|
      m = regex.match(line)
      if m
        __send__ action, m
        return true
      end
    end

    return false
  end

end

class AuthModule
  include Observer
  
  def initialize(connection, username, password)
    @username = username
    @password = password
    @connection = connection
  end

  def on_login_prompt
    @connection.send(@username)
  end

  def on_password_prompt
    @connection.send(@password)
  end

  def on_press_return_prompt
    @connection.send('')
  end
end

end
