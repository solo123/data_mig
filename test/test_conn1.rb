require 'sqlite3'
require 'active_record'
require 'logger'


puts "Active Record #{ActiveRecord::VERSION::STRING}"
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'dbfile1')

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

