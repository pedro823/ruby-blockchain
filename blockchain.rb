require './block'
require './errors'

class Blockchain
  attr_reader :chain

  def initialize
    @chain = [create_genesis_block]
  end

  def create_genesis_block
    Block.new(0, Time.now, "Genesis", 0, 0)
  end

  def latest_block
    @chain[-1]
  end


  def +(other)
    unless other.is_a? Block
      raise BlockchainError(
        "Cannot use + operator with Blockchain and #{other.class}",
        type: 'arithmetic'
      )
    end
    other.previous_hash = latest_block.hash
    other.nonce, other.hash = other.calculate_hash(other.difficulty)
    @chain << other
    return self
  end

  def valid?
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
