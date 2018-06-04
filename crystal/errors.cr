class BlockchainError < Exception

  def initialize(msg, t="generic")
    @type = t
    super(msg)
  end

end

class DatabaseError < BlockchainError
  def initialize(msg)
    super(msg, t: "database")
  end
end
