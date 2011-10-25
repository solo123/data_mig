require '../public/db_connect'

class SrcUserInfo < SourceDB
	set_table_name "userInfo"
	self.primary_key = "userId"
end
class SrcUserLogin < SourceDB
  set_table_name "userlogin"
  self.primary_key = "userId"
end

module Infos
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
  Infos::UserInfo.delete_all
  Infos::Email.delete_all("email_data_type='Infos::UserInfo'")
  Infos::Telephone.delete_all("tel_number_type='Infos::UserInfo'")
  Infos::Address.delete_all("address_data_type='Infos::UserInfo'")

	src = SrcUserInfo.where(:status => 1)
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
		lg = SrcUserLogin.find(d.id)
		
		u = Infos::UserInfo.new
		u.id = d.id
		u.first_name = d.firstName
		u.last_name = d.lastName
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

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
		STDOUT.flush
		#exit if cnt > 200
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
