require '../public/db_connect'

class SrcVehicle < SourceDB
	self.table_name = "vehicles"
	self.primary_key = "vehicleId"
end

class Bus < TargetDB
end

def do_migrate
  Bus.delete_all

	src = SrcVehicle.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		t = Bus.new
		t.name = d.vehicleName
		t.bus_type = d.vehicleType
		t.seats = d.customerSeatNum
		t.plate_number = d.plateNumber
		t.vin_number = d.vinNumber
		t.inspection_date = d.inspectionDate
		t.remark = d.notes
		t.is_own = d.own
		t.status = d.status
		t.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s 
		STDOUT.flush
	end
end

do_migrate
puts "*** DONE ****"