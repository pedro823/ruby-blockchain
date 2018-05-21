class BlockchainError < StandardError

  def initialize(msg, type='generic')
    @type = type
    super(msg)
  end

end
