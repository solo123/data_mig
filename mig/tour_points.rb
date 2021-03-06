class SrcTourDests < SourceDB
	set_table_name "tourDestinations"
	self.primary_key = "tourDestid"
end

class TourPoint < TargetDB
	has_one :description, :as => :ref
end

def mig_tourd
	TourPoint.delete_all
	Description.delete_all("ref_type='TourPoint'")
	src = SrcTourDests.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = TourPoint.new
		t.id = s.id
        t.tour_id = s.tourId
        t.destination_id = s.destinationId
        t.visit_day = s.visitDate
        t.visit_order = s.visitOrder

        t.description = Description.new
        t.description.en = gbk_utf8 s.description
        t.description.cn = gbk_utf8 s.description_cn
		t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
	end
end
