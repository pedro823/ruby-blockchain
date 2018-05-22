require './block'
require './errors'

class Blockchain
  attr_reader :chain

  def initialize
    # Initializes a blockchain.
    @chain = [create_genesis_block]
    @pending = []
    @difficulty = 4
    @mine_reward = 100
  end

  def create_genesis_block
    # Creates a first empty block.
    Block.new('0' * 64, [], 0)
  end

  def latest_block
    # Returns the latest block in the chain.
    @chain[-1]
  end

  def mine_block(miner_address)
    # Creates a block with the 100 latest transactions.
    @pending = Block.filter_invalid(@pending)
    trxs = @pending[0..100] + [Transaction.new(nil, miner_address, @mine_reward)]
    b = Block.new(latest_block.hash, trxs, @difficulty)
    b.mine
    if b.valid?
      # Block mined. Ready to remove transactions from pending
      @pending = @pending[99..-1] or []
      @chain << b
    end
  end

  def check_balance(address)
    # Checks balance of an address.
    balance = 0
    @chain.each do |block|
      block.each_transaction do |t|
        if t.from == address
          balance -= t.amount
        elsif t.to == address
          balance += t.amount
        end
      end
    end
    return balance
  end

  def add_block(block)
    other.previous_hash = latest_block.hash
    other.mine
    @chain << other
  end

  def add_transaction(transaction)
    @pending << transaction
  end

  def +(other)
    # Adds a block or a transaction to the blockchain
    if other.is_a? Block
      add_block(other)
    elsif other.is_a? Transaction or other.is_a? DataTransaction
      add_transaction(other)
    else
      raise BlockchainError.new(
        "Cannot use + operator with Blockchain and #{other.class}",
        type: 'arithmetic'
      )
    end
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
  t = Transaction.new(1, 2, 10)
  b += t
  print b.chain, "\n"
  b.mine_block(13)
  puts b.check_balance(1)
  print b.chain, "\n"
  puts b.valid?
end
