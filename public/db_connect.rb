require 'rubygems'
require 'yaml'
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(YAML.load_file("../config/database.yml")["target"])

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

def percent(i, tot)
  "#{i*100/tot}% (#{i}/#{tot})"
end

def gbk_utf8(str)
  #str ? Iconv.iconv("UTF-8//IGNORE", "gb18030//IGNORE", str).join("") : str;
  str
end



