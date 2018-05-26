class Transaction
  attr_reader :from, :to, :amount

  def self.serialize(tr)
    "tr:#{tr.from}@@#{tr.to}@@#{tr.amount}"
  end

  def self.deserialize(str)
    if str.start_with?('tr:')
      str = str[3..-1]
    else
      raise BlockchainError.new("Deserialize: not a transaction",
                                type: "serialization")
    end
    from, to, amount = str.split('@@')
    amount = amount.to_f
    return Transaction.new(from, to, amount)
  end

  def initialize(from, to, amount)
    from, to = from.to_s, to.to_s
    if from.include?('|') or to.include?('|')
      raise BlockchainError.new("Cannot have character '|' in wallet address",
                                type: "serialization")
    end
    @from = from
    @to = to
    @amount = amount
  end

  def valid?
    true
  end

  def inspect
    "<#Transaction from=#{@from} to=#{@to} amount=#{@amount}>"
  end

  def to_s
    "<#Transaction from=#{@from} to=#{@to} amount=#{@amount}>"
  end

  def serialize
    Transaction.serialize(self)
  end

end

class DataTransaction
  attr_reader :from, :data

  def self.serialize(tr)
    "dt:#{tr.from}@@#{tr.data};"
  end

  def self.deserialize(str)
    if str.start_with?('dt:')
      str = str[3..-1]
    else
      raise BlockchainError.new("Deserialize: not a transaction",
                                type: "serialization")
    end
    l = str.split('@@')
    from = l[0]
    data = l[1..-1].join('@@')[0..-2]
    return DataTransaction.new(from, data)
  end

  def initialize(from, data)
    from = from.to_s
    if from.include?('|')
      raise BlockchainError.new("Cannot have character '|' in wallet address",
                                type: "serialization")
    end
    @from = from
    @data = data
  end

  def valid?
    true
  end

  def inspect
    "<#DataTransaction from=#{@from} data='#{@data}'>"
  end

  def to_s
    "<#DataTransaction from=#{@from} data='#{@data}'>"
  end

  def serialize
    DataTransaction.serialize(self)
  end
end

# Unit testing

if __FILE__ == $0
  a = DataTransaction.new('from', '@try@@@me@@baby')
  print a.serialize, "\n"
  b = DataTransaction.deserialize(a.serialize)
  print a.data, "\n"
  print b.data, "\n"
  c = DataTransaction.new(123, '@@')
  d = DataTransaction.deserialize(c.serialize)
  print c.data, "\n"
  print d.data, "\n"
  print c.from.class, "\n"
  print d.from.class, "\n"
end
