require '../public/db_connect'

class SrcEmployeeInfo < SourceDB
	self.table_name = "EmployeeInfo"
	self.primary_key = "EmployeeID"
end
class SrcUserInfo < SourceDB
  self.table_name = "userInfo"
  self.primary_key = "userId"
end

class Employee < TargetDB
end
class EmployeeInfo < TargetDB
  has_many :telephones, :as => :tel_number
  has_many :emails, :as => :email_data
  has_many :addresses, :as => :address_data
end

class Email < TargetDB
  belongs_to :email_data, :polymorphic => :true
end
class Telephone < TargetDB
  belongs_to :tel_number, :polymorphic => :true
end
class Address < TargetDB
  belongs_to :city
  belongs_to :address_data, :polymorphic => :true
end
class City < TargetDB
end

def do_migrate
  Employee.delete_all
	EmployeeInfo.delete_all
  Email.delete_all(:email_data_type => 'Employee')
  Telephone.delete_all(:tel_number_type => 'Employee')
  Address.delete_all(:address_data_type => 'Employee')
  

	src_emps = SrcEmployeeInfo.all
	tot = src_emps.length
	cnt = 0
	src_emps.each do |src_emp|
		if $interruped
			exit
		end

		e = Employee.new
	  emp = EmployeeInfo.new
	  e.id = 	emp.id = 	src_emp.employeeID
		emp.employee_id = src_emp.employeeID if src_emp.status && src_emp.status == 1
		if !src_emp.loginName || src_emp.loginName.empty? || Employee.exists?(:login_name => src_emp.loginName)
						e.login_name = e.id.to_s
		else
				  e.login_name = src_emp.loginName
		end
		emp.pin = src_emp.password
	  emp.company_id = src_emp.companyId
	  emp.nickname = src_emp.nickname
	  emp.employ_date = src_emp.employDate
	  emp.ssn = src_emp.ssn
	  emp.birthday = src_emp.birthday
		emp.status = src_emp.status
	  if !src_emp.status || src_emp.status == 0
	  	e.locked_at = DateTime.now
	  end
	  if src_emp.status == 1 && src_emp.userId
			src_user = SrcUserInfo.find_by_userId(src_emp.userId) 
			if src_user
				if src_user.email && src_user.email.length > 3
					em = Email.new
					em.email_address = src_user.email
					emp.emails << em
				end
				if src_user.address
					ad = Address.new
					ad.address1 = src_user.address
					ad.zipcode = src_user.zip
					ad.city = find_or_create_city(src_user.city, src_user.state, src_user.country)
					emp.addresses << ad
				end
				if src_user.homePhone && src_user.homePhone.length > 3
					t = Telephone.new
					t.tel = src_user.homePhone
					t.tel_type = 'home'
					emp.telephones << t
				end
				if src_user.walkyPhone && src_user.walkyPhone.length > 3
					t = Telephone.new
					t.tel = src_user.walkyPhone
					t.tel_type = 'walky'
					emp.telephones << t
				end
				if src_user.cellPhone && src_user.cellPhone.length > 3
					t = Telephone.new
					t.tel = src_user.cellPhone
					t.tel_type = 'mobile'
					emp.telephones << t
				end
	    end
	  end
	  emp.save
		if src_user && src_user.status == 1
						e.save
		end
		cnt += 1
		print "\r" << percent(cnt,tot) << emp.id.to_s 
		STDOUT.flush
	end
end
def find_or_create_city(city, state, country)
  c = City.where(:city => city, :state => state, :country => country).first
  if !c
    c = City.new
    c.city = city
    c.state = state
    c.country = country
    c.status = 1
    c.save!
  end
  c
end
do_migrate
