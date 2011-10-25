require 'rubygems'
#gem 'activerecord', '=3.0.9'
require 'yaml'
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => 'dbfile1')
 
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

class InfosDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection YAML.load_file("../config/database.yml")["infos"]
end

class OperatesDB < ActiveRecord::Base
  self.abstract_class = true
  establish_connection YAML.load_file("../config/database.yml")["operates"]
end

def percent(i, tot)
  "#{i*100/tot}% (#{i}/#{tot})"
end

def gbk_utf8(str)
  #str ? Iconv.iconv("UTF-8//IGNORE", "gb18030//IGNORE", str).join("") : str;
  str
end



