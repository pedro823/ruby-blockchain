class BlockchainError < StandardError

  def initialize(msg, type='generic')
    @type = type
    super(msg)
  end

end

class DatabaseError < BlockchainError
  def initialize(msg)
    super(msg, type: 'database')
  end
end
