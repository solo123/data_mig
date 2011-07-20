require '../public/db_connect'

class SrcDestinations < SourceDB
	set_table_name "Destination"
	self.primary_key = "DestinationID"
end
class Destination < TargetDB
	has_one :description, :as => :ref
end
class Location < TargetDB
  has_many :locs, :class_name => 'Location', :foreign_key => 'parent_id'
  belongs_to :parent, :class_name => 'Location'
end
class Description < TargetDB
	belongs_to :ref, :polymorphic => :true
end
def do_migrate
	Destination.delete_all
	Description.delete_all("ref_type='Destination'")

  loc_root = Location.where(:parent_id => nil, :title => 'locations').first
  if !loc_root
    loc_root = Location.new
    loc.title = 'locations'
    loc.save!
  end
    
	src = SrcDestinations.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		dest = Destination.new
		dest.id = d.id
		dest.title_pic = d.titlePic
		dest.title = gbk_utf8 d.DestinationName
		dest.title_cn = gbk_utf8 d.DestinationName_cn
		dest.city = gbk_utf8 d.city
		dest.state = gbk_utf8 d.state
		dest.country = d.country
		dest.status = d.Status

		dest.description = Description.new
		dest.description.en = gbk_utf8 d.Description
		dest.description.cn = gbk_utf8 d.Description_cn
		
    if d.country
      loc = add_or_create_location(loc_root, d.country)
      if d.state
        loc = add_or_create_location(loc, gbk_utf8(d.state))
        if d.city
          loc = add_or_create_location(loc, gbk_utf8(d.city))
        end
      end
    end
		dest.location_id = loc.id if loc
		
		dest.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << dest.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end
def add_or_create_location(parent, title)
  loc = parent.locs.where(:title => title).first
  if !loc
    loc = Location.new
    loc.title = loc.title_cn = title
    parent.locs << loc
    loc.save!
  end
  loc
end

do_migrate
