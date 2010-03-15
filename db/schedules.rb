class SrcSchedules < SourceDB
	set_table_name "BusSchedule"
	self.primary_key = "scheduleId"
end

class Schedule < TargetDB
	has_one :description, :as => :ref
end

def mig_schedule
	Schedule.delete_all
	src = SrcSchedules.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Schedule.new
		t.id = s.id
        t.title = s.subTitle
        t.tour_id = s.tourId
        t.depart_date = s.startDate
        t.return_date = s.endDate
        t.vehicle_id = s.vehicleId
        t.max_seats = s.maxSeats
        t.driver_id = s.driverId
        t.driver_assistance_id = s.driverAssistanceId
        t.tour_guide_id = s.tourGuideId
        t.tour_guide_assistance_id = s.tourGuideAssistanceId
        t.book_customer = s.bookCustomers
        t.actual_customer = s.actualCustomers
        t.actual_rooms = s.actualRooms
        t.adult_price = s.priceAdult
        t.child_price = s.priceChild
        t.sales_amount = s.salesAmount
        t.create_mode = s.createMode
        t.hotels = s.hotel
        t.max_web_seats = s.maxWebSeats
        t.has_seat_table = s.hasSeatTable
        t.status = s.status

		t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
	end
end
