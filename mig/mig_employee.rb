require '../public/db_connect'

class SrcEmployeeInfo < SourceDB
	set_table_name "EmployeeInfo"
	self.primary_key = "EmployeeID"
end
class SrcUserInfo < SourceDB
  set_table_name "userInfo"
  self.primary_key = "userId"
end

class Employee < InfosDB
end
class UserInfo < InfosDB
  has_many :telephones, :as => :tel_number
  has_many :emails, :as => :email_data
  has_many :t_addresses, :as => :address_data
end
class Email < InfosDB
  belongs_to :email_data, :polymorphic => :true
end
class Telephone < InfosDB
  belongs_to :tel_number, :polymorphic => :true
end
class TAddress < InfosDB
  belongs_to :city
  belongs_to :address_data, :polymorphic => :true
end
class City < InfosDB
end

def do_migrate
  Employee.delete_all
  UserInfo.delete_all
  Email.delete_all
  Telephone.delete_all
  TAddress.delete_all
  

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
		  emp = Employee.new
		  emp.id = src_emp.id
		  emp.company_id = src_emp.companyId
		  emp.user_id = src_emp.userId
		  emp.nickname = src_emp.nickname
		  emp.employ_date = src_emp.employDate
		  emp.ssn = src_emp.ssn
		  emp.birthday = src_emp.birthday
		  emp.status = 1
		  emp.save
		  
		  d = src_user
      u = UserInfo.new
      u.user_id = d.id
      u.first_name = d.firstName
      u.last_name = d.lastName
      u.user_type = 1
      u.user_level = 9
      u.pin = src_emp.password
      u.status = d.status
      u.login = src_emp.loginName
      if d.homePhone && d.homePhone.length > 1
        tel = Telephone.new
        tel.tel_type = 'home'
        tel.tel = d.homePhone
        u.telephones << tel
      end
      if d.cellPhone && d.cellPhone.length > 1
        tel = Telephone.new
        tel.tel_type = 'mobile'
        tel.tel = d.cellPhone
        u.telephones << tel
      end
      if d.walkyPhone && d.walkyPhone.length > 1
        tel = Telephone.new
        tel.tel_type = 'walky'
        tel.tel = d.walkyPhone
        u.telephones << tel
      end
      if d.email && d.email.length > 1
        em = Email.new
        em.email_address = d.email
        u.emails << em
      end
      if d.address && d.address.length > 1
        adr = TAddress.new
        adr.address1 = d.address
        adr.city = find_or_create_city(d.city, d.state, d.country)
        adr.zipcode = d.zip
        u.t_addresses << adr
      end
      u.save!
		  
		end
		
		

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
		exit if cnt > 200
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
