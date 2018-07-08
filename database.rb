require './block.rb'
require './errors.rb'
require './transaction.rb'
require 'json'

class Database
  attr_accessor :db
  # Database containing every block in the blockchain.
  def initialize(file_name='persistance.db')
    require 'gdbm'
    # Creates database file if it doesn't exist
    @file_name = file_name
    unless File.directory?('db')
      Dir.mkdir('db/')
    end
    @db = GDBM.new('db/' + file_name)
    @wallet_db = GDBM.new('db/wallets_' + file_name)
  end

  def clear
    # Clears database and starts fresh.
    close
    File.delete('db/' + @file_name)
    @db = GDBM.new('db/' + @file_name)
  end

  def fetch_block(block_hash)
    # Linear probing
    @db.each_pair do |key, value|
      hash = JSON.parse(value)['h']
      if hash == block_hash
        return deserialize_block(value)
      end
    end
    return nil
  end

  def insert_block(index, block)
    @db[index.to_s] = serialize_block(block)
    return nil
  end

  def insert_blockchain(blockchain)
    blockchain.chain.each_index do |index|
      insert_block(index, blockchain.chain[index])
    end
  end

  def fetch_blockchain
    chain = []
    @db.each_pair do |key, value|
      chain[key.to_i] = deserialize_block(value)
    end
    return chain
  end

  def close
    @db.close
    @wallet_db.close
  end

  # Wallet related
  def wallet_exists?(wallet)
    return !!@wallet_db[wallet]
  end

  def insert_wallet(wallet, serialized_information = '')
    if wallet.empty?
      raise BlockchainError.new('Wallet address cannot be empty')
    end
    @wallet_db[wallet] = serialized_information or wallet
  end

  def delete_wallet(wallet)
    # Shouldn't be called regularly, just for debugging purposes
    @wallet_db.delete(wallet)
  end

  private

  def serialize_block(block)
    serialized_transactions = []
    block.transactions.each do |tr|
      serialized_transactions << tr.serialize
    end
    obj = {
      'h': block.hash,
      'p': block.previous_hash,
      'd': block.difficulty,
      't': block.timestamp.to_i,
      'tr': serialized_transactions,
      'n': block.nonce
    }
    return obj.to_json
  end


  def deserialize_block(str)
    obj = JSON.parse(str)
    hash = obj['h']
    previous_hash = obj['p']
    difficulty = obj['d']
    transactions = obj['tr']
    timestamp = Time.at(obj['t'])
    nonce = obj['n']
    parsed_transactions = []
    transactions.each do |tr|
      if tr.start_with?('tr:')
        parsed_transactions << Transaction.deserialize(tr)
      elsif tr.start_with?('dt:')
        parsed_transactions << DataTransaction.deserialize(tr)
      end
    end

    block = Block.new(previous_hash, parsed_transactions, difficulty, timestamp, nonce)
    if hash != block.hash
      raise DatabaseError.new("Could not validate hash for serialized block=#{str}")
    end
    return block
  end

end


# Unit Testing
if __FILE__ == $0
  require './blockchain.rb'
  transactions = [
    Transaction.new('123', '456', 28.3),
    Transaction.new('456', '789', 29.1),
    DataTransaction.new('456', 'ABC@@DEF')
  ]
  a = Block.new('0' * 64, transactions, 4)
  a.mine
  db = Database.new('test.rb')
  db.insert_block(1, a)
  b = db.fetch_block(a.hash)
  puts a, b
  print a.transactions, "\n", b.transactions, "\n"

  c = Blockchain.new
  c += a
  c += b
  c_transactions = [
    DataTransaction.new('aaa', 'something different here.'),
    Transaction.new('2311', '333', 222.1)
  ]
  c += Block.new(b.hash, c_transactions, 4)
  puts
  puts c.valid?
  puts c.chain, "\n"
  c.chain.each do |block|
    puts block
    print block.transactions, "\n"
  end
  db.clear
  db.insert_blockchain(c)
  e = Blockchain.new
  e.chain = db.fetch_blockchain
  puts
  e.chain.each do |block|
    puts block
    print block.transactions, "\n"
  end

  puts "Wallet related"
  puts db.wallet_exists?('random_wallet')
  puts db.insert_wallet('random_wallet')
  puts db.wallet_exists?('random_wallet')
  puts db.insert_wallet('random_wallet', 'stuff')
  db.delete_wallet('random_wallet')

  begin
    db.insert_wallet('')
  rescue => e
    puts e
  end

  db.close

end
