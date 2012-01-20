require '../public/db_connect'

class SrcEmployeeInfo < SourceDB
	set_table_name "EmployeeInfo"
	self.primary_key = "EmployeeID"
end
class SrcUserInfo < SourceDB
  set_table_name "userInfo"
  self.primary_key = "userId"
end
class SrcUserLogin < SourceDB
  set_table_name "userlogin"
  self.primary_key = "userId"
end

module Infos
  class Employee < InfosDB
  end
  class UserInfo < InfosDB
    has_many :telephones, :as => :tel_number
    has_many :emails, :as => :email_data
    has_many :addresses, :as => :address_data
  end
  class Email < InfosDB
    belongs_to :email_data, :polymorphic => :true
  end
  class Telephone < InfosDB
    belongs_to :tel_number, :polymorphic => :true
  end
  class Address < InfosDB
    belongs_to :city
    belongs_to :address_data, :polymorphic => :true
  end
  class City < InfosDB
  end
end
def do_migrate
	src_emps = SrcEmployeeInfo.where(:status => 1)
	tot = src_emps.length
	cnt = 0
	src_emps.each do |src_emp|
		if $interruped
			exit
		end
		cnt += 1
		print "\r" << percent(cnt,tot) << src_emp.id.to_s 
		STDOUT.flush

		emp = nil
		if Infos::Employee.exists?(src_emp.id)
			emp = Infos::Employee.find(src_emp.id)
		else
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
		if emp && emp.user_info_id && SrcUserInfo.exists?(emp.user_info_id) && SrcUserLogin.exists?(emp.user_info_id)
			unless Infos::UserInfo.exists?(emp.user_info_id)
				d = SrcUserInfo.find(emp.user_info_id)
				lg = SrcUserLogin.find(d.id)
				u = Infos::UserInfo.new
				u.id = d.id
		    u.full_name = [d.firstName, d.lastName].join(' ')
				u.user_type = 0
				u.user_level = 0
				u.login = lg.loginName
				u.pin = lg.password
				u.status = d.status
				if d.homePhone && d.homePhone.length > 1
				  tel = Infos::Telephone.new
				  tel.tel_type = 'home'
				  tel.tel = d.homePhone
				  u.telephones << tel
				end
				if d.cellPhone && d.cellPhone.length > 1
				  tel = Infos::Telephone.new
				  tel.tel_type = 'mobile'
				  tel.tel = d.cellPhone
				  u.telephones << tel
				end
				if d.walkyPhone && d.walkyPhone.length > 1
				  tel = Infos::Telephone.new
				  tel.tel_type = 'walky'
				  tel.tel = d.walkyPhone
				  u.telephones << tel
				end
				if d.email && d.email.length > 1
				  em = Infos::Email.new
				  em.email_address = d.email
				  u.emails << em
				end
				if d.address && d.address.length > 1
				  adr = Infos::Address.new
				  adr.address1 = d.address
				  adr.city = find_or_create_city(d.city, d.state, d.country)
				  adr.zipcode = d.zip
				  u.addresses << adr
				end
				u.save!				
			end
		end		
	end
end

def find_or_create_city(city, state, country)
  c = Infos::City.where(:city => city, :state => state, :country => country).first
  if !c
    c = Infos::City.new
    c.city = city
    c.state = state
    c.country = country
    c.status = 1
    c.save!
  end
  c
end

do_migrate
