class MovingWindow

  def self.scope(column = :created_at, &block)
    arel = block.binding.eval("self")
    instance = new(&block)

    Procxy.new(instance, arel, column)
  end

  def initialize(&block)
    @block = block
  end

  def filter(scope, column = :created_at, negate = false)
    qualifier = negate ? 'not between' : 'between'
    scope.where(["#{column} #{qualifier} ? and ?", *timestamps])
  end

  private
  def timestamps
    from, to = @block.call
    to ||= Time.now
    [from, to].sort
  end

  class Procxy < Struct.new(:instance, :arel, :column)
    def call
      instance.filter(arel, column, @not)
    end

    def not
      @not = !@not
      self
    end
  end

end
