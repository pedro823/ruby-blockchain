require 'securerandom'

class Wallet
  attr_reader :address

  def self.generate_address
    SecureRandom.base64(96)
  end

  def initialize(blockchain, database, address=nil)
    @blockchain = blockchain
    @db = database
    @balance_cache = 0
    @balance_cache_block_hash = ''
    if address == nil
      # Generating new wallet
      loop do
        @address = Wallet.generate_address
        break unless exists_in_chain?(@address)
      end
    else
      # Generating from chain
      unless exists_in_chain?(address)
        raise BlockchainError.new('cannot initialize wallet from fixed address' +
                                  'without the address being in the blockchain.')
      end
      @address = address
    end
  end

  def balance
    if @balance_cache_block_hash == @blockchain.latest_block.hash
      return @balance_cache
    end
    # Recalculates whole balance from chain.
    #FIXME: Inefficient. Maybe store the last index of the list of the block?
    @balance_cache_block_hash = @blockchain.latest_block.hash
    return @balance_cache = @blockchain.check_balance(@address)
  end

  def inspect
    "<Wallet @balance_cache = " \
    + @balance_cache.to_s \
    + " @balance_cache_block_hash" \
    + @balance_cache_block_hash
  end

  def to_s
    @address
  end

  private

  def exists_in_chain?(address)
    # Checks whether or not an address exists in the blockchain.
    @db.wallet_exists?(address)
  end
end

if __FILE__ == $0
  # Unit testing
  require "./blockchain.rb"
  require "./database.rb"
  require "./transaction.rb"
  # initializing blockchain
  blockchain = Blockchain.new(difficulty: 2)
  db = Database.new("test_transaction.db")
  wallet_one = Wallet.new(blockchain, db)
  wallet_two = Wallet.new(blockchain, db)
  miner_wallet = Wallet.new(blockchain, db)
  print "Wallet one address: ", wallet_one.address, "\nWallet two address: ", wallet_two.address, "\n"
  puts wallet_one.balance
  puts wallet_two.balance
  1500.times do
    tr = Transaction.new(wallet_one, wallet_two, 0.2)
    blockchain += tr
  end
  while blockchain.has_pending_transactions?
    blockchain.mine_block(miner_wallet)
  end
  puts wallet_one.balance
  puts wallet_two.balance
  puts miner_wallet.balance

end
