class SrcAdminMenu < SourceDB
	set_table_name "AdminMenu"
	self.primary_key = "menuId"
end
class Menu < TargetDB
end

def mig_menu
	puts " AdminMenu ==> menus"
	Menu.delete_all
	src = SrcAdminMenu.all
	tot = src.length
	cnt = 0
	src.each do |m|
		if $interrupted 
			exit
		end
		mn = Menu.new
		mn.id = m.id
		mn.title = m.title
		mn.description = m.description
		mn.show_order = m.menuOrder
		mn.parent_id = m.parentId
		mn.page_url = m.navigateUrl
		mn.page_name = m.pageName
		mn.role_ids = m.roleIds
		mn.position_ids = m.positionIds
		mn.need_confirm = m.needConfirm
		mn.confirm_message = m.confirmMessage
		mn.menu_type = m.menuType
		mn.app_type = m.appType
		mn.status = m.status

		mn.save!
		cnt += 1
		print "\r" << percent(cnt, tot)
		$stdout.flush
	end
	puts ""
end
