require '../public/db_connect'

class InputType < TargetDB; end

def do_migrate
	InputType.delete_all

	add_type('tour', 'Bus Tour', '1')
	add_type('tour', 'Package', '2')
	add_type('tour', 'Cruise', '3')

	add_type('bus', 'Bus', 'BUS')
	add_type('bus', 'Mini Bus', 'MBUS')
	add_type('bus', 'Van', 'VAN')

	add_type('roles', 'sales', '1')
	add_type('roles', 'driver', '2')
	add_type('roles', 'tour guide', '3')
	add_type('roles', 'manager', '4')
	add_type('roles', 'account', '5')
	add_type('roles', 'admin', 'X')

end
def add_type(type_name, type_text, type_value)
	t = InputType.new()
	t.type_name = type_name
	t.type_text = type_text
	t.type_value = type_value
	t.status = 1
	t.save
end

do_migrate
puts "*** DONE ****"
