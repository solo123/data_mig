require '../public/db_connect'

class TourType < TargetDB; end
class InputType < TargetDB; end

def do_migrate
	TourType.delete_all
	t = TourType.new(:type_name => 'Bus tour', :status => 1)
	t.save
	t = TourType.new(:type_name => 'Package', :status => 1)
	t.save
	t = TourType.new(:type_name => 'Cruise', :status => 1)
	t.save

	InputType.delete_all
	t = InputType.new(:type_name => 'bus-type', :type_text => 'Bus'); t.save
	t = InputType.new(:type_name => 'bus-type', :type_text => 'Mini Bus'); t.save
	t = InputType.new(:type_name => 'bus-type', :type_text => 'Van'); t.save
	
end

do_migrate
puts "*** DONE ****"
