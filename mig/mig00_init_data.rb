require '../public/db_connect'

class InputType < TargetDB; end

def do_migrate
	InputType.delete_all

	add_type('tour-type', 'Bus Tour', '1')
	add_type('tour-type', 'Package', '2')
	add_type('tour-type', 'Cruise', '3')
end
def add_type(type_name, type_text, type_value)
	t = InputType.new()
	t.type_name = tour_type
	t.type_text = type_text
	t.type_value = type_value
	t.status = 1
	t.save
end

do_migrate
puts "*** DONE ****"
