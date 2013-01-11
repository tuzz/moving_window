require 'rspec'
require 'moving_window'
require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

ActiveRecord::Schema.verbose = false

ActiveRecord::Schema.define do
  create_table :reviews do |table|
    table.column :published_at, :datetime
    table.timestamps
  end
end
