require 'sqlite3'
require 'active_record'
require 'logger'


puts "Active Record #{ActiveRecord::VERSION::STRING}"
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'dbfile')

ActiveRecord::Schema.define do
  create_table :users, :force => true do |t|
    t.string :name
    t.timestamps
  end
  create_table :user_infos, :force => true do |t|
    t.integer :user_id
    t.integer :info_id
    t.string :info_type
    t.string :other_info
  end
end

class MyDb < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:adapter => 'sqlite3', :database => 'dbfile')  
end

class User < MyDb
  set_primary_key :id 
  has_one :user_info
end

class UserInfo < MyDb
  belongs_to :user
end
