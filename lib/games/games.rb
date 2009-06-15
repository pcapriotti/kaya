require 'ostruct'

module Games
  GAMES = { }

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end

  def self.add(name, fields)
    GAMES[name] = OpenStruct.new(fields)
  end
  
  def self.extend(game, fields)
    get(game).dup.tap |g|
      fields.each do |field, value|
        g.send("#{field}=", value)
      end
    end
  end
end
