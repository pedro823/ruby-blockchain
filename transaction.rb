class Transaction
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
end

class DataTransaction
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
end
