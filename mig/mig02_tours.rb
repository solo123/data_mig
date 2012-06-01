require '../public/db_connect'

class SrcTour < SourceDB
	self.table_name = "tours"
	self.primary_key = "TourID"
end
class SrcTourDest < SourceDB
  self.table_name = "tourDestinations"
  self.primary_key = "tourDestid"
end

  class Tour < TargetDB
    has_one :description, :as => :desc_data, :dependent => :destroy
    has_many :spots, :order => 'visit_day, visit_order'
    has_one :tour_price
    has_one :tour_setting
  end
  class Spot < TargetDB
    self.table_name = 'tour_routes'
    has_one :description, :as => :desc_data, :dependent => :destroy
    accepts_nested_attributes_for :description, :allow_destroy => true
    
    belongs_to :tour
  end
  class TourPrice < TargetDB
    belongs_to :tour
  end
  class TourSetting < TargetDB
    belongs_to :tour
  end
  class Description < TargetDB
    belongs_to :desc_data, :polymorphic => true
  end


def do_migrate
	Tour.delete_all
	Spot.delete_all
	Description.delete_all("desc_data_type='Tour'")
	Description.delete_all("desc_data_type='Spot'")

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
    t.status = d.status
    
    t.build_tour_setting
    s = t.tour_setting		
		s.is_auto_gen = d.autoGenSchedule
		s.weekly = d.weekly
    s.has_seat_table = d.hasSeatTable
    s.is_float_price = d.isFloatPrice
		
		t.build_tour_price
		p = t.tour_price
		p.price_adult = d.priceAdult
		p.price_child = d.priceChild
		p.price1 = p.price2 = p.price3 = p.price4 = d.priceAdult
		
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
