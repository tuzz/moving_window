class MovingWindow

  def self.scope(column = :created_at, &block)
    arel = block.binding.eval("self")
    instance = new(&block)

    lambda { instance.filter(arel, column) }
  end

  def initialize(&block)
    @block = block
  end

  def filter(scope, column = :created_at)
    scope.where(["#{column} > ? and #{column} < ?", *timestamps])
  end

  private
  def timestamps
    from, to = @block.call
    to ||= Time.now
    [from, to].sort
  end

end
