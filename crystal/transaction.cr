require "./errors"

class Transaction
  getter :from, :to, :amount

  def self.serialize(tr : Transaction)
    "tr:#{tr.from}@@#{tr.to}@@#{tr.amount}"
  end

  def self.deserialize(str : String)
    if str.starts_with?("tr:")
      str = str[3..-1]
    else
      raise BlockchainError.new("Deserialize: not a transaction",
                                t: "serialization")
    end
    from, to, amount = str.split("@@")
    amount = amount.to_f
    return Transaction.new(from, to, amount)
  end

  def initialize(from : String, to : String, amount : Float64)
    if from.includes?("|") || to.includes?("|")
      raise BlockchainError.new("Cannot have character '|' in wallet address",
                                t: "serialization")
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
  getter :from, :data

  def self.serialize(tr : DataTransaction)
    "dt:#{tr.from}@@#{tr.data};"
  end

  def self.deserialize(str : String)
    if str.starts_with?("dt:")
      str = str[3..-1]
    else
      raise BlockchainError.new("Deserialize: not a transaction",
                                t: "serialization")
    end
    l = str.split("@@")
    from = l[0]
    data = l[1..-1].join("@@")[0..-2]
    return DataTransaction.new(from, data)
  end

  def initialize(from : String, data : String)
    if from.includes?("|")
      raise BlockchainError.new("Cannot have character '|' in wallet address",
                                t: "serialization")
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

file_name = Process.executable_path
if !file_name.nil? && file_name.includes?("transaction")
  a = DataTransaction.new("from", "@try@@@me@@baby")
  print a.serialize, "\n"
  b = DataTransaction.deserialize(a.serialize)
  print a.data, "\n"
  print b.data, "\n"
  c = DataTransaction.new("123", "@@")
  d = DataTransaction.deserialize(c.serialize)
  print c.data, "\n"
  print d.data, "\n"
end
