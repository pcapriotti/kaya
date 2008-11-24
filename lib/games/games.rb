module Games
  GAMES = {}

  def self.dummy
    # dummy is chess for the moment
    get(:chess)
  end

  def self.get(name)
    GAMES[name]
  end

  def self.add(name, klass)
    GAMES[name] = klass
  end
end
