class Cell
  attr_reader :column
  attr_accessor :value

  def initialize(column, value)
    @column = column
    @value = value
  end

  def to_s
    @value.to_s
  end

  def solved?
    @value != 0
  end

end