require '../public/db_connect'

class SrcSchedule < SourceDB
	self.table_name = "busschedule"
	self.primary_key = "scheduleId"
end
class SrcSeat < SourceDB
  self.table_name = "busseats"
  self.primary_key = "tourDestid"
end

class Schedule < TargetDB; end
class SchedulePrice < TargetDB; end
class ScheduleAssignment < TargetDB; end
class BusSeat < TargetDB; end

def do_migrate
  Schedule.delete_all

	src = SrcSchedule.where('startDate > "2011-10-01"')
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		
		t = Schedule.new
		t.id = d.id
    t.tour_id = d.tourId
    t.title = d.subTitle
    t.departure_date = d.startDate
    t.return_date = d.endDate
    t.book_customers = d.bookCustomers
    t.actual_customers = d.actualCustomers
    t.actual_rooms = d.actualRooms
    t.status = d.status
    t.created_at = t.updated_at = d.startDate
		t.save!

    pr = SchedulePrice.new
    pr.schedule_id = d.id
    pr.price_adult = d.priceAdult
    pr.price_child = d.priceChild
    pr.price1 = d.priceAdult
    pr.created_at = pr.updated_at = d.startDate
    pr.save!

    sa = ScheduleAssignment.new
    sa.schedule_id = d.id
    sa.bus_id = d.vehicleId
    sa.driver_id = d.driverId
    sa.driver_assistance_id = d.driverAssistanceId 
    sa.tour_guide_id = d.tourGuideId
    sa.tour_guide_assistance_id = d.tourGuideAssistanceId
    sa.created_at = sa.updated_at = d.startDate
    sa.save!

    SrcSeat.where(:scheduleId => d.id).each do |s|
      st = BusSeat.new
      st.schedule_assignment_id = sa.id
      st.seat_number = s.seatNumber
      st.order_id = s.orderId
      st.save!
    end
		
		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
	end
end

do_migrate
puts " -- end --"