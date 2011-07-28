require '../public/db_connect'

class SrcTour < SourceDB
	set_table_name "tours"
	self.primary_key = "TourID"
end
class SrcTourDest < SourceDB
  set_table_name "tourDestinations"
  self.primary_key = "tourDestid"
end

class Tour < InfosDB
  has_one :description, :as => :ref, :dependent => :destroy
  has_many :spots, :order => 'visit_day, visit_order'
end
class Spot < InfosDB
  set_table_name 'tour_routes'
  has_one :description, :as => :ref, :dependent => :destroy
  accepts_nested_attributes_for :description, :allow_destroy => true
  
  belongs_to :tour
end
class Description < InfosDB
  belongs_to :ref, :polymorphic => true
end

def do_migrate
	Tour.delete_all
	Spot.delete_all
	Description.delete_all("ref_type='Tour'")
	Description.delete_all("ref_type='Spot'")

  print "mig tours.\n"
	src = SrcTour.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		
		t = Tour.new
		t.id = d.id
		t.title = d.TourName
		t.title_cn = d.TourName_cn
		
		t.days = d.TourDay
		t.tour_type = d.TourType
		t.is_auto_gen = d.autoGenSchedule
		t.weekly = d.weekly
		t.price_adult = d.priceAdult
		t.price_child = d.priceChild
		t.has_seat_table = d.hasSeatTable
		t.is_float_price = d.isFloatPrice
		t.price1 = t.price2 = t.price3 = t.price4 = d.priceAdult
		t.status = d.status
		
		t.build_description
		t.description.en = d.Description
		t.description.cn = d.Description_cn
		t.save!
		
		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
	
	print "\nmig spots\n"
  src = SrcTourDest.all
  tot = src.length
  cnt = 0
  src.each do |d|
    if $interruped
      exit
    end
    
    s = Spot.new
    s.id = d.id
    s.tour_id = d.tourId
    s.destination_id = d.destinationId
    s.visit_day = d.visitDate
    s.visit_order = d.visitOrder
    s.status = 1
    s.build_description
    s.description.en = d.description
    s.description.cn = d.description_cn
    s.save!

    cnt += 1
    print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
    STDOUT.flush
  end
end


do_migrate
