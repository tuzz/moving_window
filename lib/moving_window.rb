class MovingWindow

  def self.scope(column = :created_at, &block)
    arel = block.binding.eval("self")
    instance = new(&block)

    Proc.new(instance, arel, column)
  end

  def initialize(&block)
    @block = block
  end

  def filter(scope, params = {})
    column, qualifier = parse(params)
    t = scope.table_name
    scope.where(["#{t}.#{column} #{qualifier} ? and ?", *timestamps])
  end

  private
  def parse(params)
    column    = params[:column] || :created_at
    qualifier = params[:negate] ? 'not between' : 'between'

    [column, qualifier]
  end

  def timestamps
    from, to = @block.call
    to ||= Time.now
    [from, to].sort
  end

  class Proc < ::Proc
    attr_writer :negate

    def initialize(*args)
      @instance, @arel, @column = args
    end

    def call
      @instance.filter(@arel, :column => @column, :negate => @negate)
    end

    def not
      clone = self.clone
      clone.negate = !@negate
      clone
    end
  end

end
