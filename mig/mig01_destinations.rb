require '../public/db_connect'

class SrcDestinations < SourceDB
	self.table_name = "Destination"
	self.primary_key = "DestinationID"
end

class Destination < TargetDB
	has_one :description, :as => :desc_data
	belongs_to :city
end
class City < TargetDB
end
class Description < TargetDB
	belongs_to :desc_data, :polymorphic => :true
end

def do_migrate
  City.delete_all
	Destination.delete_all
	Description.delete_all("desc_data_type='Destination'")

	src = SrcDestinations.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		dest = Destination.new
		dest.build_description
		
		dest.id = d.id
		dest.title = d.DestinationName
		dest.title_cn = d.DestinationName_cn
		dest.status = d.Status

		dest.description.en = d.Description
		dest.description.cn = d.Description_cn
		
		dest.city = find_or_create_city(d.city, d.state, d.country)
		
		dest.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << dest.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end
def find_or_create_city(city, state, country)
  c = City.where(:city => city, :state => state, :country => country).first
  if !c
    c = City.new
    c.city = city
    c.state = state
    c.country = country
    c.status = 1
    c.save!
  end
  c
end

do_migrate
puts "*** DONE ****"
