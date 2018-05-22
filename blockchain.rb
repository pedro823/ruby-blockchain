require './block'
require './errors'

class Blockchain
  attr_reader :chain

  def initialize
    # Initializes a blockchain.
    @chain = [create_genesis_block]
    @pending = []
    @difficulty = 4
  end

  def create_genesis_block
    # Creates a first empty block.
    Block.new('0' * 64, [], 0)
  end

  def generate_block
    # Creates a block with the 100 latest transactions.
    @pending = Block.filter_invalid(@pending)
    Block.new(latest_block.hash, @pending[0...100], @difficulty)
    @pending = @pending[100..-1] or []
  end

  def latest_block
    # Returns the latest block in the chain.
    @chain[-1]
  end

  def +(other)
    # Adds a block to the blockchain.
    unless other.is_a? Block
      raise BlockchainError.new(
        "Cannot use + operator with Blockchain and #{other.class}",
        type: 'arithmetic'
      )
    end
    other.previous_hash = latest_block.hash
    other.nonce, other.hash = other.mine(other.difficulty)
    @chain << other
    return self
  end

  def valid?
    # Checks if the state of the blockchain is consistent.
    @chain.each_index do |i|
      return false unless @chain[i].valid?
      if i != 0 and @chain[i-1].hash != @chain[i].previous_hash
        return false
      end
    end
    return true
  end
end

# Unit testing
if __FILE__ == $0
  b = Blockchain.new
  print b.chain
  puts
  o = Block.new(1, Time.now, "random data", 1, 5)
  b += o
  print b.chain, "\n"
  puts b.valid?
end
