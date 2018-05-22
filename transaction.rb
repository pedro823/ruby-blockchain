class Transaction
  attr_reader :from, :to, :amount

  def initialize(from, to, amount)
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

end

class DataTransaction
  attr_reader :from, :data

  def initialize(from, data)
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
end
