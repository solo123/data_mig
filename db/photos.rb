class SrcPhotos < SourceDB
	set_table_name "photos"
	self.primary_key = "picId"
end
class Photo < TargetDB
end
def mig_photos
	puts " Photos ==> photos"
	Photo.delete_all
	src = SrcPhotos.all
	tot = src.length
	cnt = 0
	src.each do |s|
		if $interruped
			exit
		end
		p = Photo.new
		p.id = s.id
		p.ref_id = s.relateId
		p.ref_type = 'Destination'
		p.show_order = s.picOrder
		p.title = s.title
		p.title_cn = s.title_cn
		p.status = s.status
		p.save!
		cnt += 1
		print "\r" << percent(cnt,tot)
		STDOUT.flush
	end
	puts ""
end
