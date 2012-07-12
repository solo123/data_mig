require '../public/db_connect'

class TourType < TargetDB; end

def do_migrate
	TourType.delete_all
	t = TourType.new(:type_name => 'Bus tour', :status => 1)
	t.save
	t = TourType.new(:type_name => 'Package', :status => 1)
	t.save
	t = TourType.new(:type_name => 'Cruise', :status => 1)
	t.save

	
end

do_migrate
puts "*** DONE ****"
