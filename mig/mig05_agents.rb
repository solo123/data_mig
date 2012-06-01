require '../public/db_connect'

class SrcCompany < SourceDB
	self.table_name = "company"
	self.primary_key = "companyId"
end
class SrcUserLogin < SourceDB
  self.table_name = "userlogin"
  self.primary_key = "userId"
end

class Agent < TargetDB
	has_many :contacts
	has_one :agent_account
end
class Contact < TargetDB
  has_many :telephones, :as => :tel_number
  has_many :emails, :as => :email_data
  has_many :addresses, :as => :address_data
end
class AgentAccount < TargetDB
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
  Agent.delete_all
  Contact.delete_all
  AgentAccount.delete_all

  Email.delete_all(:email_data_type => 'Contact')
  Telephone.delete_all(:tel_number_type => 'Contact')
  Address.delete_all(:address_data_type => 'Contact')

	src = SrcCompany.all
	tot = src.length
	cnt = 0
	src.each do |d|
		if $interruped
			exit
		end
	  agent = Agent.new
	  agent.id = d.id
	  agent.short_name = d.shortName
	  agent.company_name = d.companyName
	  agent.icon_url = d.iconUrl
	  agent.website = d.website
	  agent.remark = [d.description, d.description_cn].join(" ")
	  agent.status = d.status
	  ac = agent.build_agent_account
	  ac.discount = d.discount
	  ac.max_credit = d.maxCredit
	  ac.balance = d.creditBalance
	  
	  c = Contact.new
	  c.contact_name = d.contactPerson
	  agent.contacts << c
	  if d.telephone
	  	t = Telephone.new
	  	t.tel_type = 'tel'
	  	t.tel = d.telephone
	  	c.telephones << t
	  end
	  if d.fax
	  	t = Telephone.new
	  	t.tel_type = 'fax'
	  	t.tel = d.fax
	  	c.telephones << t
	  end
	  addr = Address.new
	  addr.address1 = d.address
	  addr.zipcode = d.zip
	  addr.city = find_or_create_city(d.city, d.state, d.country)
	  c.addresses << addr

		agent.save!

		cnt += 1
		print "\r" << percent(cnt,tot) << d.id.to_s # << " : " << dest.title_cn 
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
