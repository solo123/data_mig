class SrcEmployee < SourceDB
  set_table_name "EmployeeInfo"
  self.primary_key = "employeeID"
end
class Employee < TargetDB
end

def app_employee
  src = SrcEmployee.all
	tot = src.length
	cnt = 0
  cnt1 = 0
	src.each do |s|
    cnt += 1
    print "\r --ee--" << percent(cnt, tot) << " [" << s.id.to_s << "]" << cnt1.to_s
    STDOUT.flush

    next if Employee.exists? s.id
		t = Employee.new
		t.id = s.id
    t.nick_name = s.nickname
    t.login_name = s.loginName
    t.password = s.password
    t.userinfo_id = s.userId
    t.employ_date = s.employDate
    t.ssn = s.ssn
    t.birthday = s.birthday
    t.company_id = s.companyId
    t.status = s.status
    t.roles = (SrcEmployee.find_by_sql ["select roleID from userRole where employeeID=? and roleType=1",s.id]).map {|m| m.roleID}.join(",")
    t.positions = (SrcEmployee.find_by_sql ["select roleID from userRole where employeeID=? and roleType=2",s.id]).map {|m| m.roleID}.join(",")
    t.save!
    cnt1 += 1
  end
end
