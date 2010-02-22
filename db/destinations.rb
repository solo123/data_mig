
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
	puts " Destination ==> destinations"
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
		dest.title = d.DestinationName
		dest.title_cn = d.DestinationName_cn
		dest.city = d.city
		dest.state = d.state
		dest.country = d.country
		dest.status = d.Status

		dest.description = Description.new
		dest.description.en = d.Description
		dest.description.cn = d.Description_cn

		dest.save!

		cnt += 1
		print "\r" << percent(cnt,tot) 
		STDOUT.flush
	end
	puts ""
end
