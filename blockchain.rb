require './block.rb'
require './errors.rb'
require './wallet.rb'

class Blockchain
  attr_accessor :chain

  def initialize(difficulty: 4, mine_reward: 100)
    # Initializes a blockchain.
    @chain = [create_genesis_block]
    @pending = []
    @difficulty = difficulty
    @mine_reward = mine_reward
  end

  def create_genesis_block
    # Creates a first empty block.
    Block.new('0' * 64, [], 0)
  end

  def create_genesis_wallet(database)
    require 'securerandom'
    wallet_prefix = 'genesis_wallet_'
    genesis_wallet_address = wallet_prefix + SecureRandom.base64(96 - wallet_prefix.length)
    tr = Transaction.new(nil, genesis_wallet_address, 1e6 - @mine_reward)
    @pending << tr
    mine_block(genesis_wallet_address)
    database.insert_wallet(genesis_wallet_address, '{ "info": "hello world!" }')
    return Wallet.new(self, database, genesis_wallet_address)
  end

  def latest_block
    # Returns the latest block in the chain.
    @chain[-1]
  end

  def mine_block(miner_address)
    # Creates a block with the 100 latest transactions.
    @pending = Block.filter_invalid(@pending)
    trxs = @pending[0...99] + [Transaction.new(nil, miner_address, @mine_reward)]
    b = Block.new(latest_block.hash, trxs, @difficulty)
    b.mine
    if b.valid?
      # Block mined. Ready to remove transactions from pending
      @pending = @pending[99..-1] || []
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
    block.previous_hash = latest_block.hash
    block.mine
    @chain << block
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

  def has_pending_transactions?
    @pending.length > 0
  end

  def status(database)
    puts '#--- Blockchain report ---#'
    puts 'Blocks:'
    @chain.each do |block|
      puts ' ' * 4 + block.inspect
    end
    puts
    puts 'Wallets inserted in the database:'
    database.each_wallet do |key, wallet|
      puts ' ' * 4 + 'address: ' + key + ' information: ' + wallet.inspect
    end
    puts 'Pending transactions:'
    @pending.each do |tr|
      puts tr
    end
    puts 'valid?'
    puts ' ' * 4 + valid?.to_s
    puts '#-------------------------#'
  end
end

# Unit testing
if __FILE__ == $0
  require './database.rb'
  b = Blockchain.new
  print b.chain
  puts
  t = Transaction.new(1, 2, 10)
  b += t
  print b.chain, "\n"
  b.mine_block('123')
  puts b.check_balance(1)
  print b.chain, "\n"
  puts b.valid?
  b.chain = b.chain.reverse
  puts b.valid?
  b.chain = b.chain.reverse

  # genesis wallet
  db = Database.new('test_blockchain.rb')
  puts b.create_genesis_wallet(db)
  b.status(db)
  db.clear
  db.close
end
