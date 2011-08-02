require '../public/db_connect'

class SrcUserInfo < SourceDB
	set_table_name "userInfo"
	self.primary_key = "userId"
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
  UserInfo.delete_all

	src = SrcUserInfo.where(:status => 1)
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		
		u = UserInfo.new
		u.id = d.id
		u.first_name = d.firstName
		u.last_name = d.lastName
		u.user_type = 0
		u.user_level = 0
		u.pin = d.pin
		u.status = d.status
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
