
# TODO:
# src.titlePic ==> copy to directory
class SrcDestinations < SourceDB
	set_table_name "Destination"
	self.primary_key = "DestinationID"
end
class Destination < TargetDB
	has_one :description, :as => :ref
end
class Description < TargetDB
	belongs_to :ref, :polymorphic => :true
end
def mig_dest
	Destination.delete_all
	Description.delete_all("ref_type='Destination'")
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
		
		dest.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << dest.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end
