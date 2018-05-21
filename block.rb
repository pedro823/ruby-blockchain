require 'digest'

class Block
  attr_accessor :hash, :previous_hash, :nonce
  attr_reader :data, :timestamp, :index, :difficulty

  def initialize(index, timestamp, previous_hash, data, difficulty)
    @index = index
    @timestamp = timestamp
    @previous_hash = previous_hash
    @data = data
    @difficulty = difficulty
    calculate_hash(difficulty)
  end

  def hash
    Digest::SHA256.hexdigest( # Hashes all data inside block
      @index.to_s + @timestamp.to_s + @previous_hash + @data.to_s + @nonce.to_s
    )
  end

  def calculate_hash(difficulty = 2)
    @nonce = 0
    validation = '0' * difficulty
    loop do
      if hash.start_with? validation
        return @nonce
      else
        @nonce += 1
      end
    end
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
