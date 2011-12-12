require '../public/db_connect'

class SrcEmployeeInfo < SourceDB
	set_table_name "EmployeeInfo"
	self.primary_key = "EmployeeID"
end
class SrcUserInfo < SourceDB
  set_table_name "userInfo"
  self.primary_key = "userId"
end

module Infos
  class Employee < InfosDB
  end
end
def do_migrate
  Infos::Employee.delete_all
  #Infos::UserInfo.delete_all
  #Infos::Email.delete_all
  #Infos::Telephone.delete_all
  #Infos::Address.delete_all
  

	src_emps = SrcEmployeeInfo.where(:status => 1)
	tot = src_emps.length
	cnt = 0
	src_emps.each do |src_emp|
		if $interruped
			exit
		end
		
		src_user = nil
		src_user = SrcUserInfo.find(src_emp.userId) if src_emp.userId
		if src_user
		  emp = Infos::Employee.new
		  emp.id = src_emp.id
		  emp.company_id = src_emp.companyId
		  emp.user_info_id = src_emp.userId
		  emp.nickname = src_emp.nickname
		  emp.employ_date = src_emp.employDate
		  emp.ssn = src_emp.ssn
		  emp.birthday = src_emp.birthday
		  emp.status = 1
		  emp.save
    end
		cnt += 1
		print "\r" << percent(cnt,tot) << emp.id.to_s 
		STDOUT.flush
	end
end

do_migrate
