require '../public/db_connect'

class InputType < TargetDB; end
class AppConfiguration < TargetDB; end

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

	add_type('company', 'aetravel', '1')
	add_type('company', 'agent', '2')
	add_type('company', 'tour company', '3')
  add_type('company', 'hotel', '4')
  add_type('company', 'bus company', '5')

	add_type('tel', 'home', 'home')
	add_type('tel', 'mobile', 'mobile')
	add_type('tel', 'walky', 'walky')
	add_type('tel', 'tel', 'tel')
	add_type('tel', 'fax', 'fax')

  add_type('order.status', 'new', '0')
  add_type('order.status', 'order', '1')
  add_type('order.status', 'paid', '2')
  add_type('order.status', 'full_paid', '3')
  add_type('order.status', 'cancled', '7')
  add_type('order.status', 'finished', '8')

  add_type('todo.level', 'normal', '1')
  add_type('todo.level', 'important', '2')
  add_type('todo.level', 'urgent', '3')
  add_type('todo.level', 'error', '4')

  add_type('todo.status', 'new', '0')
  add_type('todo.status', 'doing', '1')
  add_type('todo.status', 'done', '2')
  add_type('todo.status', 'cancled', '4')
  add_type('todo.status', 'finished', '8')

  AppConfiguration.delete_all
  add_config(:site_name, 'website title', 'AETravel')
  add_config(:admin_list_per_page, "List lines per page in admin", '20')
  add_config(:admin_path, "the admin path", '/aeadmin')
  add_config(:max_reservation_days, "The max days auto-create schedules on the auto-gen tours", "90")

end
def add_type(type_name, type_text, type_value)
	t = InputType.new()
	t.type_name = type_name
	t.type_text = type_text
	t.type_value = type_value
	t.status = 1
	t.save
end
def add_config(key, title, val)
  c = AppConfiguration.new
  c.key = key.to_s
  c.title = title
  c.val = val
  c.parent_id = 0
  c.save
end

do_migrate
puts "*** DONE ****"
