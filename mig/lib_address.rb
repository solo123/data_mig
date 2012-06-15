class Address < TargetDB
  belongs_to :city
  belongs_to :address_data, :polymorphic => :true
end
class City < TargetDB; end

def add_address(city, state, country, zip, address)
  adr = Address.new
  adr.address1 = address
  adr.city = find_or_create_city(city, state, country)
  adr.zipcode = zip
  adr
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