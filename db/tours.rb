class SrcTours < SourceDB
	set_table_name "tours"
	self.primary_key = "TourID"
end

class Tour < TargetDB
	has_one :description, :as => :ref
end

def mig_tour
	puts " tours ==> tours"
	Tour.delete_all
	Description.delete_all("ref_type='Tour'")
	src = SrcTours.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Tour.new
		t.id = s.id
		t.name = gbk_utf8 s.TourName
		t.name_cn = gbk_utf8 s.TourName_cn
		t.show_order = s.tourOrder
		t.days = s.TourDay
		t.tour_type = s.TourType
		t.auto_gen_schedule = s.autoGenSchedule
		t.weekly = s.weekly
		t.price_adult = s.priceAdult * 100
		t.price_child = s.priceChild * 100
		t.has_seat_table = s.hasSeatTable
		t.is_float_price = s.isFloatPrice

		t.description = Description.new
		t.description.en = gbk_utf8 s.Description
		t.description.cn = gbk_utf8 s.Description_cn
		t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
	end
	puts ""
end
