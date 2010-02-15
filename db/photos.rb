
class SrcPhotos < SourceDB
	set_table_name "photos"
	self.primary_key = "picId"
end
class DestPhoto < TargetDB
end
def mig_photos
	puts " Photos ==> dest_photos"
	DestPhoto.delete_all
	SrcPhotos.all.each do |s|
		if $interruped
			exit
		end
		p = DestPhoto.new
		p.id = s.id
		p.destination_id = s.relateId
		p.title = s.title
		p.title_cn = s.title_cn
		p.status = s.status
		p.save!
		print "\r" << p.id.to_s << p.title << "                               "
		STDOUT.flush
	end
	puts ""
end
