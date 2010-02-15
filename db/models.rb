require '../public/db_connect'
class SrcAdminMenu < SourceDB
	set_table_name "AdminMenu"
	self.primary_key = "menuId"
end
