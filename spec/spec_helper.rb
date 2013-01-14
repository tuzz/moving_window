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
    table.column :user_id, :integer
    table.timestamps
  end

  create_table :users do |table|
    table.timestamps
  end
end
