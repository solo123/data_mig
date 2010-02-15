require 'rubygems'
require 'yaml'
require 'active_record'
 
class SourceDB < ActiveRecord::Base
  self.abstract_class = true
  config = YAML.load_file("../config/database.yml")["source"]
  establish_connection(config)
end

class TargetDB < ActiveRecord::Base
  self.abstract_class = true
  config = YAML.load_file("../config/database.yml")["target"]
  establish_connection(config)
end





