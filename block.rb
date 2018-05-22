require 'digest'
require './errors'
require './transaction'

class Block
  attr_accessor :hash, :previous_hash, :nonce
  attr_reader :data, :timestamp, :index, :difficulty, :transactions

  # CLASS METHODS

  def self.filter_invalid(transactions)
    valid = []
    transactions.each do |t|
      if t.valid?
        valid << t
      end
    end
    return valid
  end

  # INSTANCE METHODS

  def initialize(previous_hash, transactions, difficulty)
    @timestamp = Time.now
    @previous_hash = previous_hash
    if transactions.length > 100
      raise BlockchainError(
        "Cannot initialize Block with more than 100 transactions. (Got: #{transactions.length})"
      )
    end
    @transactions = Block.filter_invalid(transactions)
    @difficulty = difficulty
    @nonce = 0
  end

  def hash
    Digest::SHA256.hexdigest( # Hashes all data inside block
      @timestamp.to_s + @previous_hash + @transactions.to_s + @data.to_s + @nonce.to_s
    )
  end

  def mine
    # Finds a nonce so that the hash has difficulty amounts of 0s at the start.
    validation = '0' * @difficulty
    loop do
      if hash.start_with? validation
        return @nonce
      else
        @nonce += 1
      end
    end
  end

  def each_transaction
    # Yield all transactions that are valid.
    @transactions.each do |t|
        yield t if t.valid?
    end
  end

  def +(other)
    # Adds a transaction to a block
    unless other.is_a? Transaction or other.is_a? DataTransaction
      raise BlockchainError.new(
        "Cannot use + operator with Block and #{other.class}, expected Transaction or DataTransaction",
        type: 'arithmetic'
      )
    end
    if @transactions.length >= 100
      raise BlockchainError.new(
        "Cannot append to Block: list is full",
        type: 'procedural'
      )
    end
    @transactions << other
    return self
  end

  def valid?
    hash.start_with? '0' * @difficulty
  end

  def inspect
    "#<Block hash_10=#{hash[-10..-1]} nonce=#{@nonce} prev_hash=#{@previous_hash[0..10]}>"
  end

  def to_ary
    ["#<Block hash_10=#{hash[-10..-1]} nonce=#{@nonce} prev_hash=#{@previous_hash[0..10]}>"]
  end

  def to_s
    "Block index=#{@index} nonce=#{@nonce} hash=#{hash} timestamp=#{@timestamp}"
  end

end


# Unit testing
if __FILE__ == $0
  transactions = [
    Transaction.new(1, 2, 10),
    Transaction.new(2, 3, 10),
    Transaction.new(3, 4, 10),
    DataTransaction.new(3, 'Hello i am legit')
  ]
  b = Block.new('0' * 64, transactions, 3)
  puts b.hash
  puts b.valid?
  b.mine
  puts b.hash
  puts b.valid?
  print b.transactions, "\n"
  begin
    100.times do |i|
      a = Transaction.new(2, i, 10)
      b += a
    end
  rescue => e
    puts e
    puts b.valid?
    b.mine
    puts b.valid?
  end
end
