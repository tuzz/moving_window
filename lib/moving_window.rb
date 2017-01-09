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
    query = columns_sql(scope.table_name, Array.wrap(column))
    scope.where(["#{query} #{qualifier} ? and ?", *timestamps])
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

  def columns_sql(table_name, columns)
    columns_string = columns.map { |name| "#{table_name}.#{name}" }.join(',')
    columns.length > 1 ? "COALESCE(#{columns_string})" : columns_string
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
