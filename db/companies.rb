class SrcCompany < SourceDB
	set_table_name "Company"
	self.primary_key = "companyId"
end

class Company < TargetDB
  	has_one :description, :as => :ref
end

def mig_company
    Company.delete_all
	src = SrcCompany.all
	tot = src.length
	cnt = 0
	src.each do |s|
		t = Company.new
		t.id = s.id
        t.abbreviation = s.shortName
        t.name = s.companyName
        t.name_cn = s.companyName_cn
        t.address = s.address
        t.city = s.city
        t.state = s.state
        t.country = s.country
        t.zip = s.zip
        t.phone = s.telephone
        t.fax = s.fax
        t.contact = s.contactPerson
        t.email = s.email
        t.company_type = s.companyType
        t.icon = s.iconUrl
        t.website = s.website
        t.description = Description.new
        t.description.en = s.description
        t.description.cn = s.description_cn
        t.discount = s.discount
        t.max_credit = s.maxCredit
        t.credit_balance = s.creditBalance
        t.status = s.status
        t.save!

		cnt += 1
		print "\r" << percent(cnt, tot)
		STDOUT.flush
    end

end
