require "active_record"

require 'belongs_to_tenant'
require 'shoulda-matchers'

ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => ':memory:'
})